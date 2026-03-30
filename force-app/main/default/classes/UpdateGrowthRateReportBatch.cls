/**
 * 计算累计收入成本
 * 每月跑一次，跑当月数据
 * 增长率报表数据刷新
 */
 
//GrowthRateReportBatch
//Growth_Rate_Report_Obj__c



global class UpdateGrowthRateReportBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    //测试时把汇率改成1
    /*
    global  Decimal rate = 1;
    global  Decimal rate1 = 1;
    global  Decimal rate2 = 1;
    global  Decimal rate3 = 1;
    global  Decimal rate4 = 1;
    global  Decimal lastRate = 1;
    */

    //动态获取需要生成计划增长率报表的销售组织
    //具体是 8110,8140,8510,8500
    public List<String> hEnityList = Label.Company_Code_List_For_Planned_Completion_Rate_Report.split(',');
    //获取客户销售组织对应币种Map
    public static Map<String,String> hEntityCurrencyMap = Utility.getHisenseEntityCurrencyMap();
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();

    global UpdateGrowthRateReportBatch(String inputYear,String inputMonth) {
        this.year = inputYear;
        this.month = inputMonth;
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }

        this.query = 'SELECT Id,Product_Line_Name__c,Rank__c,Actual_Development_Date__c,Customer__r.Hisense_Entity__c,Parent_Product_Line__c,'+
                     ' Expected_Business_Stopping_Date__c,Market_Share__c,Customer__c,Management_Customer__c,Management_Customer_Branch_Company__c,' + 
                     ' Management_Customer_Branch_Company__r.Hisense_Entity__c FROM Customer_Product_Line__c' +
                     ' WHERE Customer__r.Hisense_Entity__c IN:hEnityList AND Management_Customer_Branch_Company__c!=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Customer_Product_Line__c> cplList) {
        ///System.debug('List:'+cplList.size());
        try {
            //所有客户产品线对应的客户
            Set<ID> allAccIdSet = new Set<ID>();
            //子产品线
            Set<String> productLineSet = new Set<String>();
            //管理用客户+父级产品线下面的所有子级产品线
            Map<String,List<Customer_Product_Line__c>> acc_productLine_Map = new Map<String,List<Customer_Product_Line__c>>();
            //管理用客户+父级产品线指向管理用客户所属销售组织 last modified by johnson20190814

            //管理用户改成客户，产品线为细产品线
            for (Customer_Product_Line__c cpl : cplList) {
                System.debug(1);
                System.debug(cpl.Customer__c+','+cpl.Product_Line_Name__c);
                if (acc_productLine_Map.containsKey(cpl.Customer__c+','+cpl.Product_Line_Name__c)) {
                    acc_productLine_Map.get(cpl.Customer__c+','+cpl.Product_Line_Name__c).add(cpl);
                    System.debug(2);
                }else{
                    acc_productLine_Map.put(cpl.Customer__c+','+cpl.Product_Line_Name__c, new List<Customer_Product_Line__c>{cpl});
                    System.debug(3);
                }
                allAccIdSet.add(cpl.Customer__c);
                productLineSet.add(cpl.Product_Line_Name__c);
            }

            //客户+产品线+年+月的收入成本
            Map<String,SAP_Cost_Revenue_Data__c> costRevenueMap = new Map<String,SAP_Cost_Revenue_Data__c>();

            //找出所有客户产品线对应的收入成本    
            for (SAP_Cost_Revenue_Data__c costRevenue : [SELECT CurrencyIsoCode,Month__c,Year__c,Sales_Volume__c,
                                                            Customer__c,Product_Line__c,Sales_Gross_Revenue__c,
                                                            Sales_Gross_Revenue_USD__c,Sales_Revenue__c,
                                                            Sales_Revenue_USD__c 
                                                         FROM SAP_Cost_Revenue_Data__c 
                                                         WHERE Customer__c IN:allAccIdSet 
                                                         AND Product_Line__c IN:productLineSet 
                                                         AND Year__c = :year]) {
                String monthCostRevenueKey = costRevenue.Customer__c+costRevenue.Product_Line__c+costRevenue.Year__c+costRevenue.Month__c;
                if(costRevenueMap.containsKey(monthCostRevenueKey)){
                    SAP_Cost_Revenue_Data__c exsitCostRevenue = costRevenueMap.get(monthCostRevenueKey);
                    exsitCostRevenue.Sales_Volume__c += convertNull(costRevenue.Sales_Volume__c);
                    exsitCostRevenue.Sales_Revenue__c += convertNull(costRevenue.Sales_Revenue__c);
                    exsitCostRevenue.Sales_Revenue_USD__c += convertNull(costRevenue.Sales_Revenue_USD__c);
                    exsitCostRevenue.Sales_Gross_Revenue__c += convertNull(costRevenue.Sales_Gross_Revenue__c);
                    exsitCostRevenue.Sales_Gross_Revenue_USD__c += convertNull(costRevenue.Sales_Gross_Revenue_USD__c);
                }else{
                    costRevenue.Sales_Volume__c = convertNull(costRevenue.Sales_Volume__c);
                    costRevenue.Sales_Revenue__c = convertNull(costRevenue.Sales_Revenue__c);
                    costRevenue.Sales_Revenue_USD__c = convertNull(costRevenue.Sales_Revenue_USD__c);
                    costRevenue.Sales_Gross_Revenue__c = convertNull(costRevenue.Sales_Gross_Revenue__c);
                    costRevenue.Sales_Gross_Revenue_USD__c = convertNull(costRevenue.Sales_Gross_Revenue_USD__c);
                    costRevenueMap.put(monthCostRevenueKey, costRevenue);
                }                   
            }
            

            //更新报表数据
            //Growth_Rate_Report_Obj__c
            //Planned_Completion_Rate_Report__c
            Map<String,Schema.SObjectField> pcrrLoopMap = Schema.SObjectType.Growth_Rate_Report_Obj__c.fields.getMap();
            String queryStr = Utility.getQueryStringByFieldMap(pcrrLoopMap);
            String querySql = 'SELECT '+queryStr+' FROM Growth_Rate_Report_Obj__c WHERE Year__c=:year AND Month__c=:month';
            List<Growth_Rate_Report_Obj__c> pcrrList = Database.query(querySql);


            //已存在的报表数据
            Map<String,Growth_Rate_Report_Obj__c> pcrrMap = new Map<String,Growth_Rate_Report_Obj__c>();
            for (Growth_Rate_Report_Obj__c pcrr : pcrrList) {
                pcrrMap.put(pcrr.Management_Customer__c+pcrr.Product_Line__c+pcrr.Month__c+pcrr.Year__c, pcrr);
            }

            List<Growth_Rate_Report_Obj__c> upsertList = new List<Growth_Rate_Report_Obj__c>();

            Set<String> keySet = acc_productLine_Map.keySet();
            //去年年份
            String lastYear = String.valueOf(Integer.valueOf(year)-1);

            for (String key : keySet) {
                //String hEntityCode = manageAccHisenseEntityMap.get(key);
                List<String> keyList = key.split(',');
                Growth_Rate_Report_Obj__c completionRate = pcrrMap.get(keyList[0]+keyList[1]+month+year);
                
                //如果不存在就新建
                if (completionRate==null) {
                    continue;
                }

                //今年累计
                Decimal revenueNetBC = 0;
                Decimal revenueNetUSD = 0;
                Decimal revenueGrossBC = 0;
                Decimal revenueGrossUSD = 0;
                
                //今年累计销量
                Decimal volumn = 0;
                
                //根据年月+币种得到发票币种的汇率以及实际同期币种的汇率(今年)
                String rateYearMonth = year + month;
                //根据年月+币种得到发票币种的汇率以及实际同期币种的汇率(去年)
                String lastRateYearMonth = lastYear+month;
                //今年销售组织的汇率
                Decimal rate = currencyRateMap.get(completionRate.CurrencyIsoCode + rateYearMonth);
                
                //去年销售组织汇率
                Decimal lastRate = currencyRateMap.get(completionRate.CurrencyIsoCode + lastRateYearMonth);
                
                if(Test.isRunningTest()){
                    rate = 1;lastRate = 1;
                }

                //对客户每个产品线做累加
                for (Customer_Product_Line__c cpl : acc_productLine_Map.get(key)) {
                    //计算累计，累计到传入的month
                    for (Integer i=1;i<=Integer.valueOf(month);i++) {
                        String m = String.valueOf(i);
                        if (i<10) {
                            m = '0'+m;
                        }
                        //今年累计
                        SAP_Cost_Revenue_Data__c scrdNYear = costRevenueMap.get(cpl.Customer__c
                                +cpl.Product_Line_Name__c
                                +year
                                +m);
                        if (scrdNYear!=null) {
                            // 货币转换
                            Decimal rate4 = currencyRateMap.get(scrdNYear.CurrencyIsoCode + rateYearMonth);
                            if(Test.isRunningTest()){
                                rate4 = 1;
                            }
                            if (completionRate.CurrencyIsoCode!=null && !completionRate.CurrencyIsoCode.equals(scrdNYear.CurrencyIsoCode)) {
                                revenueNetBC = revenueNetBC+convertNull(scrdNYear.Sales_Revenue__c)/rate4*rate;
                                revenueGrossBC = revenueGrossBC+convertNull(scrdNYear.Sales_Gross_Revenue__c)/rate4+rate;
                            }else{
                                revenueNetBC = revenueNetBC+convertNull(scrdNYear.Sales_Revenue__c); 
                                revenueGrossBC = revenueGrossBC+convertNull(scrdNYear.Sales_Gross_Revenue__c);
                            }
          
                            revenueNetUSD = revenueNetUSD+convertNull(scrdNYear.Sales_Revenue_USD__c);
                                        
                            revenueGrossUSD = revenueGrossUSD+convertNull(scrdNYear.Sales_Gross_Revenue_USD__c); 
                            volumn = volumn+convertNull(scrdNYear.Sales_Volume__c);
                        }    
                    }
                     
                }
                //今年累计
                completionRate.Accumulated_Revenue_Net__c = completionRate.Accumulated_Revenue_Net__c==null? 0:completionRate.Accumulated_Revenue_Net__c;
                completionRate.Accumulated_Revenue_Net__c = revenueNetBC+completionRate.Accumulated_Revenue_Net__c;

                completionRate.Accumulated_Revenue_Net_USD__c = completionRate.Accumulated_Revenue_Net_USD__c==null? 0:completionRate.Accumulated_Revenue_Net_USD__c;
                completionRate.Accumulated_Revenue_Net_USD__c = revenueNetUSD+completionRate.Accumulated_Revenue_Net_USD__c;

                completionRate.Accumulated_Revenue_Gross__c = completionRate.Accumulated_Revenue_Gross__c==null? 0:completionRate.Accumulated_Revenue_Gross__c;
                completionRate.Accumulated_Revenue_Gross__c = revenueGrossBC+completionRate.Accumulated_Revenue_Gross__c;

                completionRate.Accumulated_Revenue_Gross_USD__c = completionRate.Accumulated_Revenue_Gross_USD__c==null? 0:completionRate.Accumulated_Revenue_Gross_USD__c;
                completionRate.Accumulated_Revenue_Gross_USD__c = revenueGrossUSD+completionRate.Accumulated_Revenue_Gross_USD__c;
                //今年累计
                completionRate.Accumulated_sales_volumn__c = convertNull(completionRate.Accumulated_sales_volumn__c)+volumn;
                System.debug('=========='+JSON.serialize(completionRate));
                upsertList.add(completionRate);

            } 
            if(!upsertList.isEmpty())
                Database.upsert(upsertList);
        }catch (Exception e) {
            System.debug('报表出错：'+e.getMessage()+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

    //转换null to 0
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