global class ComparisonSalesReportBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;
    public String day;

    global ComparisonSalesReportBatch(String inputYear,String inputMonth,String inputDay) {
        this.year = inputYear;
        this.month = inputMonth;
        this.day = inputDay;
        this.query = 'SELECT Invoice_Net_Income_USD__c,Sales_Region__c,Customer_Product_Line__r.Product_Line_Name__c,Customer__c,Customer_Product_Line__c,Customer_Group2__c,Customer_SAP_Code_From_SAP__c,Product_Line_SF_Text__c,Sales_Orgnization__c,Year__c,Month__c,Date__c FROM '+
        'SAP_Sales_Actual__c WHERE Year__c=:year AND Month__c=:month AND Date__c=:day';


        System.debug('this.query:  '+this.query);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<SAP_Sales_Actual__c> SAPSalesActualList) {
        Savepoint sp = Database.setSavepoint();
        try {
            //客户ID
            Set<ID> customerIdSet = new Set<ID>();
            //产品线ID
            Set<ID> productLineIdSet = new Set<ID>();
            //销售组织
            Set<String> hisenseEntitySet = new Set<String>();
            //客户code
            Set<String> customerCodeSet = new Set<String>();
            //产品线code
            Set<String> productLineTextSet = new Set<String>();
            //产品线
            Set<String> productLineSet = new Set<String>();
            Map<String,List<SAP_Sales_Actual__c>> SAPSalesActualMap = new Map<String,List<SAP_Sales_Actual__c>>();
            for (SAP_Sales_Actual__c salesActual : SAPSalesActualList) {
                customerCodeSet.add(salesActual.Customer_SAP_Code_From_SAP__c);
                productLineTextSet.add(salesActual.Product_Line_SF_Text__c);
                hisenseEntitySet.add(salesActual.Sales_Orgnization__c);
                customerIdSet.add(salesActual.Customer__c);
                productLineIdSet.add(salesActual.Customer_Product_Line__c);
                productLineSet.add(salesActual.Customer_Product_Line__r.Product_Line_Name__c);
                String key = salesActual.Customer_SAP_Code_From_SAP__c+','+salesActual.Sales_Orgnization__c+','+salesActual.Product_Line_SF_Text__c;
                if (SAPSalesActualMap.containsKey(key)) {
                    SAPSalesActualMap.get(key).add(salesActual);
                }else{
                    SAPSalesActualMap.put(key, new List<SAP_Sales_Actual__c>{salesActual});
                }
            }   

            //客户  产品线 entity对应的Sales Target
            Map<String,Sales_Target__c> salesTargetMap = new Map<String,Sales_Target__c>();
            //获取salesTarget所有的字段
            Map<String,Schema.SObjectField> salesTargetLoopMap = Schema.SObjectType.Sales_Target__c.fields.getMap();
            String queryStr = Utility.getQueryStringByFieldMap(salesTargetLoopMap);
            String lastYear = String.valueOf(Integer.valueOf(year)-1);
            String querySql = 'SELECT '+queryStr+',Customer_Name__r.Sales_Region__c,Customer_Name__r.Name FROM Sales_Target__c '+
                              'WHERE Customer_Name__c IN:customerIdSet AND Customer_Product_Line__c IN:productLineIdSet '+
                              'AND (Year__c=:year OR Year__c=:lastYear)';
            List<Sales_Target__c> salesTargetList = Database.query(querySql);                  

            //根据Account的ID map salesTarget
            Map<Id,List<Sales_Target__c>> stMap = new Map<Id,List<Sales_Target__c>>();
            for (Sales_Target__c st : salesTargetList) {
                salesTargetMap.put(st.Customer_Name__c+st.Year__c+st.Customer_Product_Line__c, st);
            }

            Map<String,Comparison_Sales_Report_YoY__c> comparisonSalesMap = new Map<String,Comparison_Sales_Report_YoY__c>();
            //已存在的报表数据
            List<Comparison_Sales_Report_YoY__c> lastDayComparisonSalesList = [SELECT Completed_Amount_MoD_USD__c,ID,Customer_Code__c,Hisense_Entity__c,Product_Line_Code__c,Year__c,Month__c,Date__c FROM Comparison_Sales_Report_YoY__c WHERE Customer_Code__c IN:customerCodeSet
                                                                         AND Product_Line_Code__c IN:productLineTextSet AND Hisense_Entity__c IN:hisenseEntitySet
                                                                         AND Year__c=:year AND Month__c=:month AND Date__c=:day];
            for (Comparison_Sales_Report_YoY__c comparisonSales : lastDayComparisonSalesList) {
                comparisonSalesMap.put(comparisonSales.Customer_Code__c+comparisonSales.Hisense_Entity__c+comparisonSales.Product_Line_Code__c, comparisonSales);                                                        
            }                                                         
            String lastMonth;
            if (!'1'.equals(month)) {
                lastMonth = String.valueOf(Integer.valueOf(month)-1);
            }else{
                lastMonth = month;
            }
            //对应客户  产品线的损益表
            Map<String,Revenue_Statement_Report__c> revenueStatemnetMap = new Map<String,Revenue_Statement_Report__c>();
            for (Revenue_Statement_Report__c rsr : [SELECT Actual_Revenue_Same_Period_USD__c,N_Year_Actual_Accumulated_Revenue_USD__c,Customer__c,Product_Line__c,Year__c,Month__c FROM Revenue_Statement_Report__c
                WHERE Customer__c IN:customerIdSet AND Product_Line__c IN:productLineSet  AND Year__c =:year AND Month__c =:lastMonth]) {
                revenueStatemnetMap.put(rsr.Customer__c+rsr.Product_Line__c, rsr);
            }

            String beforeLastMonth;
            Map<String,Revenue_Statement_Report__c> beforeLastRevenueStatemnetMap = new Map<String,Revenue_Statement_Report__c>();
            if (!'1'.equals(month)&&!'2'.equals(month)) {
                beforeLastMonth = String.valueOf(Integer.valueOf(month)-2);
                for (Revenue_Statement_Report__c rsr : [SELECT Actual_Revenue_Same_Period_USD__c,N_Year_Actual_Accumulated_Revenue_USD__c,Customer__c,Product_Line__c,Year__c,Month__c FROM Revenue_Statement_Report__c
                    WHERE Customer__c IN:customerIdSet AND Product_Line__c IN:productLineSet  AND Year__c =:year AND Month__c =:beforeLastMonth]) {
                    beforeLastRevenueStatemnetMap.put(rsr.Customer__c+rsr.Product_Line__c, rsr);
                }
            }

            //需要新添的Sales report
            List<Comparison_Sales_Report_YoY__c> newCompaisonSalesList = new List<Comparison_Sales_Report_YoY__c>();
            Set<String> keyList = SAPSalesActualMap.keySet();
            for (String salesActualKey : keyList) {
                //计算同一纬度的收入的总和
                Decimal dec = 0;
                for (SAP_Sales_Actual__c SAPsalesActual : SAPSalesActualMap.get(salesActualKey)) {
                    SAPsalesActual.Invoice_Net_Income_USD__c = SAPsalesActual.Invoice_Net_Income_USD__c==null? 0:SAPsalesActual.Invoice_Net_Income_USD__c;
                    dec = dec + SAPsalesActual.Invoice_Net_Income_USD__c;
                }
                List<SAP_Sales_Actual__c> saList = SAPSalesActualMap.get(salesActualKey);
                //获取到一个维度中的一个SAPSalesActual
                SAP_Sales_Actual__c sa = saList[0];
                List<String> strList = salesActualKey.split(',');
                Comparison_Sales_Report_YoY__c comparisonSalesReprot = comparisonSalesMap.get(strList[0]+strList[1]+strList[2]);
                Comparison_Sales_Report_YoY__c comparisonSales;
                if (comparisonSalesReprot!=null) {
                    comparisonSales = comparisonSalesReprot;
                }else{
                    comparisonSales = new Comparison_Sales_Report_YoY__c();
                    comparisonSales.Customer_Group__c = sa.Customer_Group2__c;
                    comparisonSales.Customer__c = sa.Customer__c;
                    comparisonSales.Product_Line__c = sa.Customer_Product_Line__c;
                    comparisonSales.Hisense_Entity__c = sa.Sales_Orgnization__c;
                    comparisonSales.Sales_Region__c = sa.Sales_Region__c;
                    comparisonSales.Customer_Code__c = sa.Customer_SAP_Code_From_SAP__c;
                    comparisonSales.Product_Line_Code__c = sa.Product_Line_SF_Text__c;
                    comparisonSales.Year__c = sa.Year__c;
                    comparisonSales.Month__c = sa.Month__c;
                    comparisonSales.Date__c = sa.Date__c;
                    comparisonSales.CurrencyIsoCode = 'USD';
                    comparisonSalesMap.put(sa.Customer_SAP_Code_From_SAP__c+sa.Sales_Orgnization__c+sa.Product_Line_SF_Text__c, comparisonSales);
                }
                Sales_Target__c st = salesTargetMap.get(sa.Customer__c+sa.Year__c+sa.Customer_Product_Line__c);
                List<Decimal> decList = planIncome(month,st);
                comparisonSales.Sales_Target_Month__c = decList==null? null:decList[0];
                    // if ('1'.equals(day)) {
                comparisonSales.Completed_Amount_MoD_USD__c = comparisonSales.Completed_Amount_MoD_USD__c==null? 0:comparisonSales.Completed_Amount_MoD_USD__c;
                comparisonSales.Completed_Amount_MoD_USD__c = comparisonSales.Completed_Amount_MoD_USD__c+dec;
                    // }else{
                    //     Comparison_Sales_Report_YoY__c lastComparisonSales = comparisonSalesMap.get(sa.Customer_SAP_Code_From_SAP__c+sa.Sales_Orgnization__c+sa.Product_Line_SF_Text__c);
                    //     //如果为null转换为0
                    //     lastComparisonSales.Completed_Amount_MoD_USD__c = lastComparisonSales.Completed_Amount_MoD_USD__c==null? 0:lastComparisonSales.Completed_Amount_MoD_USD__c;
                    //     comparisonSales.Completed_Amount_MoD_USD__c = sa.Invoice_Net_Income_USD__c+lastComparisonSales.Completed_Amount_MoD_USD__c;
                    // }
                Revenue_Statement_Report__c rsr = revenueStatemnetMap.get(sa.Customer__c+sa.Customer_Product_Line__r.Product_Line_Name__c);
                if (rsr!=null) {
                    rsr.N_Year_Actual_Accumulated_Revenue_USD__c = rsr.N_Year_Actual_Accumulated_Revenue_USD__c==null? 0:rsr.N_Year_Actual_Accumulated_Revenue_USD__c;
                }
                Sales_Target__c lastSt = salesTargetMap.get(sa.Customer__c+lastYear+sa.Customer_Product_Line__c);
                decList = planIncome(month,lastSt);
                comparisonSales.Completed_Amount_Month_of_Last_Year_USD__c = decList==null? 0:decList[1];
                if ('1'.equals(month)) {
                    comparisonSales.Completed_Amount_YoD_USD__c = comparisonSales.Completed_Amount_MoD_USD__c;
                }else{
                    if (rsr!=null) {
                        comparisonSales.Completed_Amount_YoD_USD__c = rsr.N_Year_Actual_Accumulated_Revenue_USD__c+comparisonSales.Completed_Amount_MoD_USD__c;
                    }
                }

                if ('1'.equals(month)) {//如果为1月份则Accumulated_Amount_Last_Year_USD__c就是1月份的同期收入
                    comparisonSales.Accumulated_Amount_Last_Year_USD__c = comparisonSales.Completed_Amount_Month_of_Last_Year_USD__c; 
                }else if ('2'.equals(month)) {//为2月份时Accumulated_Amount_Last_Year_USD__c是2月份同期收入+1月份同期收入
                    decList = planIncome('1',lastSt);
                    comparisonSales.Accumulated_Amount_Last_Year_USD__c = comparisonSales.Completed_Amount_Month_of_Last_Year_USD__c+decList[1];
                }else{//如果为其他月份则 是N-2月Revenue_Statement_Report__c中同期收入+N月同期收入+N-1月同期收入
                    Revenue_Statement_Report__c beforeLastrsr = beforeLastRevenueStatemnetMap.get(sa.Customer__c+sa.Customer_Product_Line__r.Product_Line_Name__c);
                    decList = planIncome(lastMonth,lastSt);
                    if (beforeLastrsr!=null) {
                        beforeLastrsr.Actual_Revenue_Same_Period_USD__c = beforeLastrsr.Actual_Revenue_Same_Period_USD__c==null? 0:beforeLastrsr.Actual_Revenue_Same_Period_USD__c;
                        comparisonSales.Accumulated_Amount_Last_Year_USD__c = beforeLastrsr.Actual_Revenue_Same_Period_USD__c+comparisonSales.Completed_Amount_Month_of_Last_Year_USD__c+decList[1];
                    }
                }
                newCompaisonSalesList.add(comparisonSales);
            }
            Database.upsert(newCompaisonSalesList);
        }catch (Exception e) {
            System.debug('创建数据失败：'+e.getMessage()+e.getLineNumber());
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('ComparisonSalesReportBatch', errorMsg);
        }
    }

    global void finish(Database.BatchableContext BC) {
        ComparisonSalesReportShareBatch csrShare = new ComparisonSalesReportShareBatch(year,month);
        Database.executeBatch(csrShare,200);
    }

    //获取当月计划收入和去年当月实际收入
    public List<Decimal> planIncome(String month,Sales_Target__c st){
        if (st==null) {
           return null; 
        }
        List<Decimal> decList = new List<Decimal>();
        Decimal dec;
        Decimal lastDec;
        switch on month {
            when '1'{
                dec = st.Estimated_Sales_Income_January_USD__c;
                lastDec = st.Actual_Sales_Income_January_USD__c;
            }    
            when '2'{
                dec = st.Estimated_Sales_Income_February_USD__c;
                lastDec = st.Actual_Sales_Income_February_USD__c;
            }                                
            when '3'{
                dec = st.Estimated_Sales_Income_March_USD__c;
                lastDec = st.Actual_Sales_Income_March_USD__c;
            }    
            when '4'{
                dec = st.Estimated_Sales_Income_April_USD__c;
                lastDec = st.Actual_Sales_Income_April_USD__c;
            }    
            when '5'{
                dec = st.Estimated_Sales_Income_May_USD__c;
                lastDec = st.Actual_Sales_Income_May_USD__c;
            }    
            when '6'{
                dec = st.Estimated_Sales_Income_June_USD__c;
                lastDec = st.Actual_Sales_Income_June_USD__c;
            }    
            when '7'{
                dec = st.Estimated_Sales_Income_July_USD__c;
                lastDec = st.Actual_Sales_Income_July_USD__c;
            }     
            when '8'{
                dec = st.Estimated_Sales_Income_Augest_USD__c;
                lastDec = st.Actual_Sales_Income_Augest_USD__c;
            }    
            when '9'{
                dec = st.Estimated_Sales_Income_September_USD__c;
                lastDec = st.Actual_Sales_Income_September_USD__c;
            }    
            when '10'{
                dec = st.Estimated_Sales_Income_October_USD__c;
                lastDec = st.Actual_Sales_Income_October_USD__c;
            }    
            when '11'{
                dec = st.Estimated_Sales_Income_November_USD__c;
                lastDec = st.Actual_Sales_Income_November_USD__c;
            }    
            when '12'{
                dec = st.Estimated_Sales_Income_December_USD__c;
                lastDec = st.Actual_Sales_Income_November_USD__c;
            }
        } 
        decList.add(dec);
        decList.add(lastDec);
        return decList;          
    }
}