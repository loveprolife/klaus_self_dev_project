/**********************************************************************
* Name: SalesTargetBatch
* Object: Sales_Target__c 
* Purpose: 
* 年度销售目标与销售实绩对比表Batch
* Author: Gerry
* Create Date: 2019-03-12
*************************************************************************/
global class SalesTargetBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;
    public String inputYear;
    public String inputMonth;

    global SalesTargetBatch(String year,String month) {
        this.inputYear = year;
        this.inputMonth = month;
        if ('1'.equals(month)) {
            this.year = String.valueOf(Integer.valueOf(year)-1);
            this.month = '12';
        }else{
            this.year = year;
            this.month = String.valueOf(Integer.valueOf(month)-1);
            if (Integer.valueOf(this.month)<10) {
                this.month = '0'+this.month;
            }
        }
        this.query = 'SELECT Id,Customer__r.Name,Customer__r.Guarantor_Country_Code__c,Year__c,Company_Code__r.CurrencyIsoCode,CurrencyIsoCode,Customer_Product_Line__r.Management_Customer__c,'+
                     'Sales_Revenue__c,Month__c,Product_Line__c,Sales_Revenue_USD__c,Customer__r.Sales_Region__c,Sales_Volume__c,Cost_USD__c,Cost__c,Hisense_Entity__c '+
                     'FROM SAP_Cost_Revenue_Data__c WHERE Year__c=:year AND Month__c=:month AND Product_Line__c!=null AND Customer__c!=null AND Customer_Product_Line__r.Management_Customer__c!=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<SAP_Cost_Revenue_Data__c> revenueDataList) {
        //产品线集合
        Set<String> productLineSet = new Set<String>();
        //客户集合
        Set<String> customerSet = new Set<String>();
        Set<String> countrySet = new Set<String>();

        //小客户集合
        List<SAP_Cost_Revenue_Data__c> smallCostList = new List<SAP_Cost_Revenue_Data__c>();

        for (SAP_Cost_Revenue_Data__c revenueData : revenueDataList) {
            productLineSet.add(revenueData.Product_Line__c);
            //如果Customer__c和Management_Customer__c一致就取Customer__c，不一致取Management_Customer__c
            if (revenueData.Customer__c != revenueData.Customer_Product_Line__r.Management_Customer__c) {
                customerSet.add(revenueData.Customer_Product_Line__r.Management_Customer__c);
            }else{
                customerSet.add(revenueData.Customer__c);
            }
        }

        Map<String,Customer_Product_Line__c> customerProMap = new Map<String,Customer_Product_Line__c>();
        //因为Customer和Management Customer可能会不同（母公司子公司）要统计的是Management Customer的product Line  
        for (Customer_Product_Line__c cpl : [SELECT Management_Customer__c,Product_Line_Name__c,Customer__c FROM Customer_Product_Line__c 
                                             WHERE Product_Line_Name__c IN :productLineSet AND Customer__c IN :customerSet]) {
            customerProMap.put(cpl.Product_Line_Name__c+cpl.Customer__c, cpl);
        }

        String year = this.year;
        String month = this.month;

        Map<String,Schema.SObjectField> salesTargetLoopMap = Schema.SObjectType.Sales_Target__c.fields.getMap();
        String queryStr = Utility.getQueryStringByFieldMap(salesTargetLoopMap);
        String querySql = 'SELECT '+queryStr+',Customer_Name__r.Guarantor_Country_Code__c,Customer_Name__r.Name FROM Sales_Target__c '+
                          'WHERE Customer_Name__c IN:customerSet AND Product_Line__c IN:productLineSet '+
                          'AND Year__c = :year';
        List<Sales_Target__c> salesTargetList = Database.query(querySql);
        System.debug('SalesTarget:'+salesTargetList);
        //设置每个产品线下的所有salesTarget
        Map<String,Sales_Target__c> stMap = new Map<String,Sales_Target__c>();
        for (Sales_Target__c st : salesTargetList) {
            stMap.put(st.Customer_Name__c+st.Product_Line__c, st);
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();//Last modified by johnson20190711
            //汇率本位币跟USD的汇率
            Decimal rate;
            //cost中币种跟USD的汇率
            Decimal rate1;
            for (SAP_Cost_Revenue_Data__c costRevenue : revenueDataList) {
                //Last modified by johnson20190711
                String rateYearMonth = costRevenue.Year__c + costRevenue.Month__c;
                rate = currencyRateMap.get(costRevenue.Company_Code__r.CurrencyIsoCode + rateYearMonth);
                rate1 = currencyRateMap.get(costRevenue.CurrencyIsoCode + rateYearMonth);
                if(Test.isRunningTest()){
                    rate = 1;rate1 = 1;
                }

                //获取同步到sf数据的产品线所对应的target
                ID costId = costRevenue.Customer__c;
                if (costRevenue.Customer__c != costRevenue.Customer_Product_Line__r.Management_Customer__c) {
                    costId = costRevenue.Customer_Product_Line__r.Management_Customer__c;
                }
                Sales_Target__c st = stMap.get(costId+costRevenue.Product_Line__c);
                if (st==null) {
                    st = new Sales_Target__c();
                    st.Customer_Name__c = costId;
                    st.Product_Line__c = costRevenue.Product_Line__c;
                    st.Year__c = year;
                    //系统中不存在的salesTarget才添加进去
                    salesTargetList.add(st);
                    stMap.put(st.Customer_Name__c+st.Product_Line__c, st);
                }
                st.Hisense_Entity__c = costRevenue.Hisense_Entity__c;
                st.CurrencyIsoCode = costRevenue.Company_Code__r.CurrencyIsoCode;
                if (costRevenue.CurrencyIsoCode.equals(costRevenue.Company_Code__r.CurrencyIsoCode)) {
                    costRevenue.Cost__c = costRevenue.Cost__c==null? 0:costRevenue.Cost__c;
                    costRevenue.Sales_Revenue__c = costRevenue.Sales_Revenue__c==null? 0:costRevenue.Sales_Revenue__c;
                }else{
                    //如果币种不一样，先转换为美元，之后转换为本位币
                    costRevenue.Cost__c = (costRevenue.Cost__c==null? 0:costRevenue.Cost__c) / rate1 * rate;
                    costRevenue.Sales_Revenue__c = (costRevenue.Sales_Revenue__c==null? 0:costRevenue.Sales_Revenue__c) / rate1 * rate;
                }
                costRevenue.Sales_Revenue_USD__c = costRevenue.Sales_Revenue_USD__c==null? 0:costRevenue.Sales_Revenue_USD__c;
                costRevenue.Sales_Volume__c = costRevenue.Sales_Volume__c==null? 0:costRevenue.Sales_Volume__c;
                Customer_Product_Line__c cpl = customerProMap.get(st.Product_Line__c+st.Customer_Name__c);

                if (cpl!=null) {
                    st.Customer_Product_Line__c = cpl.Id;
                }else{
                    st.Customer_Product_Line__c = null;
                }
                switch on month {
                    when '01'{
                        st.Actual_Income_in_January__c = costRevenue.Sales_Revenue__c+convertNull(st.Actual_Income_in_January__c);
                        st.Actual_Sales_Income_January_USD__c = convertNull(st.Actual_Sales_Income_January_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_January__c = convertNull(st.Actual_Sales_in_January__c)+costRevenue.Sales_Volume__c;
                        st.Cost_January__c = convertNull(st.Cost_January__c)+costRevenue.Cost__c;
                    }    
                    when '02'{
                        st.Actual_Income_in_February__c = convertNull(st.Actual_Income_in_February__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_February_USD__c = convertNull(st.Actual_Sales_Income_February_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_February__c = convertNull(st.Actual_Sales_in_February__c)+costRevenue.Sales_Volume__c;
                        st.Cost_February__c = convertNull(st.Cost_February__c)+costRevenue.Cost__c;
                    }                                
                    when '03'{
                        st.Actual_Income_in_March__c = convertNull(st.Actual_Income_in_March__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_March_USD__c = convertNull(st.Actual_Sales_Income_March_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_March__c = convertNull(st.Actual_Sales_in_March__c)+costRevenue.Sales_Volume__c;
                        st.Cost_March__c = convertNull(st.Cost_March__c)+costRevenue.Cost__c;
                    }    
                    when '04'{
                        st.Actual_Income_in_April__c = convertNull(st.Actual_Income_in_April__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_April_USD__c = convertNull(st.Actual_Sales_Income_April_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_April__c = convertNull(st.Actual_Sales_in_April__c)+costRevenue.Sales_Volume__c;
                        st.cost_April__c = convertNull(st.cost_April__c)+costRevenue.Cost__c;
                    }    
                    when '05'{
                        st.Actual_Income_in_May__c = convertNull(st.Actual_Income_in_May__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_May_USD__c = convertNull(st.Actual_Sales_Income_May_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_May__c = convertNull(st.Actual_Sales_in_May__c)+costRevenue.Sales_Volume__c;
                        st.Cost_May__c = convertNull(st.Cost_May__c)+costRevenue.Cost__c;
                    }    
                    when '06'{
                        st.Actual_Income_in_June__c = convertNull(st.Actual_Income_in_June__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_June_USD__c = convertNull(st.Actual_Sales_Income_June_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_June__c = convertNull(st.Actual_Sales_in_June__c)+costRevenue.Sales_Volume__c;
                        st.Cost_June__c = convertNull(st.Cost_June__c)+costRevenue.Cost__c;
                    }    
                    when '07'{
                        st.Actual_Income_in_July__c = convertNull(st.Actual_Income_in_July__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_July_USD__c = convertNull(st.Actual_Sales_Income_July_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_July__c = convertNull(st.Actual_Sales_in_July__c)+costRevenue.Sales_Volume__c;
                        st.Cost_July__c = convertNull(st.Cost_July__c)+costRevenue.Cost__c;
                    }     
                    when '08'{
                        st.Actual_Income_in_August__c = convertNull(st.Actual_Income_in_August__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_Augest_USD__c = convertNull(st.Actual_Sales_Income_Augest_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_August__c = convertNull(st.Actual_Sales_in_August__c)+costRevenue.Sales_Volume__c;
                        st.Cost_Augest__c = convertNull(st.Cost_Augest__c)+costRevenue.Cost__c;
                    }    
                    when '09'{
                        st.Actual_Income_in_September__c = convertNull(st.Actual_Income_in_September__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_September_USD__c = convertNull(st.Actual_Sales_Income_September_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_September__c = convertNull(st.Actual_Sales_in_September__c)+costRevenue.Sales_Volume__c;
                        st.Cost_September__c = convertNull(st.Cost_September__c)+costRevenue.Cost__c;
                    }    
                    when '10'{
                        st.Actual_Income_in_October__c = convertNull(st.Actual_Income_in_October__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_October_USD__c = convertNull(st.Actual_Sales_Income_October_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_October__c = convertNull(st.Actual_Sales_in_October__c)+costRevenue.Sales_Volume__c;
                        st.Cost_October__c = convertNull(st.Cost_October__c)+costRevenue.Cost__c;
                    }    
                    when '11'{
                        st.Actual_Income_in_November__c = convertNull(st.Actual_Income_in_November__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_November_USD__c = convertNull(st.Actual_Sales_Income_November_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_November__c = convertNull(st.Actual_Sales_in_November__c)+costRevenue.Sales_Volume__c;
                        st.Cost_November__c = convertNull(st.Cost_November__c)+costRevenue.Cost__c;
                    }    
                    when '12'{
                        st.Actual_Income_in_December__c = convertNull(st.Actual_Income_in_December__c)+costRevenue.Sales_Revenue__c;
                        st.Actual_Sales_Income_December_USD__c = convertNull(st.Actual_Sales_Income_December_USD__c)+costRevenue.Sales_Revenue_USD__c;
                        st.Actual_Sales_in_December__c = convertNull(st.Actual_Sales_in_December__c)+costRevenue.Sales_Volume__c;
                        st.Cost_December__c = convertNull(st.Cost_December__c)+costRevenue.Cost__c;
                    }    
                }        
            }
            System.debug(salesTargetList);
            Database.upsert(salesTargetList);
            System.debug('修改成功:'+salesTargetList.size());
        }catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('SalesTargetBatch', errorMsg);
        }  
    }
    global void finish(Database.BatchableContext BC) {
        // //SAP成本收入权限Share
        SAPGetRevenueCostShareBatch sapRCShare = new SAPGetRevenueCostShareBatch(inputYear,inputMonth);
        Database.executeBatch(sapRCShare,200);
 
        // //SalesTarget权限Share
        SalesTargetShareBatch salesTargetShare = new SalesTargetShareBatch(inputYear);
        Database.executeBatch(salesTargetShare,200);

        //SAP成本收入权限Share
        Share_Common_IntegrationBatch sapRCShareBatch = new Share_Common_IntegrationBatch(
            'SAP_Cost_Revenue_Data__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(sapRCShareBatch, 30);

        //SalesTarget权限Share
        Share_Common_IntegrationBatch salesTargetShareBatch = new Share_Common_IntegrationBatch(
            'Sales_Target__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(salesTargetShareBatch, 30);

        //生成Revenue Statement Report报表数据
        RevenueStatementReportBatch rsReport = new RevenueStatementReportBatch(inputYear,inputMonth);
        Database.executeBatch(rsReport,200);
        //生成整体战略客户汇总报表数据
        StrategyCustomerReportBatch scReport = new StrategyCustomerReportBatch(inputYear,inputMonth);
        Database.executeBatch(scReport,200);
        //生成整体优质客户汇总报表数据
        QualityCustomerReportBatch qcReport = new QualityCustomerReportBatch(inputYear,inputMonth);
        Database.executeBatch(qcReport,200);
        //生成原有战略客户汇总报表数据
        OriginalCustomerReportBatch ocReport = new OriginalCustomerReportBatch(inputYear,inputMonth);
        Database.executeBatch(ocReport,200);
    }

    //转换'' to 0
    private static Decimal convertNull(Decimal num) {
        Decimal strConvert;
        if(num == null) {
            strConvert = 0;
        }else{
            strConvert = num;
        } 
        return strConvert;
    }
}