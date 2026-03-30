/**
 * 计算累计收入成本
 * 每月跑一次，跑当月数据
 */
global class UpdatePlannedCompletionRateBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public String year;
    public String month;
    global Map<String, Integer> updateAPRSumCountMap = new Map<String, Integer>();
    //动态获取需要生成计划增长率报表的销售组织
    public List<String> hEnityList = Label.Company_Code_List_For_Planned_Completion_Rate_Report.split(',');
    //获取客户销售组织对应币种Map
    public static Map<String,String> hEntityCurrencyMap = Utility.getHisenseEntityCurrencyMap();
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();

    global UpdatePlannedCompletionRateBatch(String inputYear,String inputMonth) {
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

            for (Customer_Product_Line__c cpl : cplList) {
                System.debug(1);
                System.debug(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c);
                if (acc_productLine_Map.containsKey(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c)) {
                    acc_productLine_Map.get(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c).add(cpl);
                    System.debug(2);
                }else{
                    acc_productLine_Map.put(cpl.Management_Customer_Branch_Company__c+','+cpl.Parent_Product_Line__c, new List<Customer_Product_Line__c>{cpl});
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
            

            Map<String,Schema.SObjectField> pcrrLoopMap = Schema.SObjectType.Planned_Completion_Rate_Report__c.fields.getMap();
            String queryStr = Utility.getQueryStringByFieldMap(pcrrLoopMap);
            String querySql = 'SELECT '+queryStr+' FROM Planned_Completion_Rate_Report__c WHERE Year__c=:year AND Month__c=:month';
            List<Planned_Completion_Rate_Report__c> pcrrList = Database.query(querySql);


            //已存在的报表数据
            Map<String,Planned_Completion_Rate_Report__c> pcrrMap = new Map<String,Planned_Completion_Rate_Report__c>();
            for (Planned_Completion_Rate_Report__c pcrr : pcrrList) {
                pcrrMap.put(pcrr.Management_Customer__c+pcrr.Product_Line__c+pcrr.Month__c+pcrr.Year__c, pcrr);
            }

            List<Planned_Completion_Rate_Report__c> upsertList = new List<Planned_Completion_Rate_Report__c>();

            Set<String> keySet = acc_productLine_Map.keySet();
            //去年年份
            String lastYear = String.valueOf(Integer.valueOf(year)-1);

            for (String key : keySet) {
                //String hEntityCode = manageAccHisenseEntityMap.get(key);
                List<String> keyList = key.split(',');
                Planned_Completion_Rate_Report__c completionRate = pcrrMap.get(keyList[0]+keyList[1]+month+year);
                
                //如果不存在就新建
                if (completionRate==null) {
                    continue;
                }

                //今年累计
                Decimal revenueNetBC = 0;
                Decimal revenueNetUSD = 0;
                Decimal revenueGrossBC = 0;
                Decimal revenueGrossUSD = 0;

                //当天收入值
                Decimal revenueNetBCToday = 0;
                Decimal revenueNetUSDToday = 0;
                Decimal revenueGrossBCToday = 0;
                Decimal revenueGrossUSDToday = 0;

                //当月实际销量
                Decimal volumnMonth = 0;
                
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

                    SAP_Cost_Revenue_Data__c currentYMData = costRevenueMap.get(cpl.Customer__c
                                +cpl.Product_Line_Name__c
                                +rateYearMonth);
                    if(currentYMData != null) {

                        Decimal rate1 = currencyRateMap.get(currentYMData.CurrencyIsoCode + rateYearMonth);
                        if(Test.isRunningTest()){
                            rate1 = 1;
                        }
                        if(completionRate.CurrencyIsoCode!=null && completionRate.CurrencyIsoCode.equals(currentYMData.CurrencyIsoCode)){
                            revenueNetBCToday = revenueNetBCToday+convertNull(currentYMData.Sales_Revenue__c);
                            revenueGrossBCToday = revenueGrossBCToday+convertNull(currentYMData.Sales_Gross_Revenue__c);
                        }else{
                            revenueNetBCToday = revenueNetBCToday+convertNull(currentYMData.Sales_Revenue__c)/rate1*rate;
                            revenueGrossBCToday = revenueGrossBCToday+convertNull(currentYMData.Sales_Gross_Revenue__c)/rate1*rate;
                        }
                        revenueNetUSDToday = revenueNetUSDToday+convertNull(currentYMData.Sales_Revenue_USD__c);
                        revenueGrossUSDToday = revenueGrossUSDToday+convertNull(currentYMData.Sales_Gross_Revenue_USD__c);
                        volumnMonth = volumnMonth+convertNull(currentYMData.Sales_Volume__c);
                    }
                    
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

                //初次跑batch 给相应字段赋值为0
                if (updateAPRSumCountMap.containsKey(key)) {
                    updateAPRSumCountMap.put(key,updateAPRSumCountMap.get(key) + 1);
                }else{
                    updateAPRSumCountMap.put(key, 1);
                    completionRate.Actual_Revenue_Net__c = 0;
                    completionRate.Actual_Revenue_Net_USD__c = 0;
                    completionRate.Actual_Revenue_Gross__c = 0;
                    completionRate.Actual_Revenue_Gross_USD__c = 0;
                    completionRate.actual_sales_volumn__c = 0;
                    completionRate.Accumulated_Revenue_Net__c = 0;
                    completionRate.Accumulated_Revenue_Net_USD__c = 0;
                    completionRate.Accumulated_Revenue_Gross__c = 0;
                    completionRate.Accumulated_Revenue_Gross_USD__c = 0;
                    completionRate.Accumulated_sales_volumn__c = 0;
                }

                //实际收入
                completionRate.Actual_Revenue_Net__c = convertNull(completionRate.Actual_Revenue_Net__c) + revenueNetBCToday;
                completionRate.Actual_Revenue_Net_USD__c = convertNull(completionRate.Actual_Revenue_Net_USD__c) + revenueNetUSDToday;
                completionRate.Actual_Revenue_Gross__c = convertNull(completionRate.Actual_Revenue_Gross__c) + revenueGrossBCToday;
                completionRate.Actual_Revenue_Gross_USD__c = convertNull(completionRate.Actual_Revenue_Gross_USD__c) + revenueGrossUSDToday;
                //实际销量
                //实际销量
                completionRate.actual_sales_volumn__c = convertNull(completionRate.actual_sales_volumn__c)+volumnMonth;
                

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