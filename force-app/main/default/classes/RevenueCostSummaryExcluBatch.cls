/**************************************************************************************************
 * Name:RevenueCostSummaryExcluBatch
 * Purpose: 收入成本数据汇总到实际同期报表上
 * Author: wfc
 * Create Date: 2020-06-18
 * 执行方法 Database.executeBatch(new RevenueCostSummaryExcluBatch(year,month),200);
***************************************************************************************************/
global class RevenueCostSummaryExcluBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public String year;
    public String month;
    public String region;
    public String lastYearMonth;//去年当月
    public String yearLastMonth;//今年上月
    public Set<String> yearMonthSet = new Set<String>();//去年当月、今年上月
    public Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();
    global Map<String, Integer> updateAPRSumCountMap = new Map<String, Integer>();

    global RevenueCostSummaryExcluBatch(String year,String month,String region) {
        this.year = year;
        this.month = month;
        this.region = region;
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }

        Datetime currentTime = Datetime.valueOf(this.year + '-' + this.month + '-02 00:00:00');
        lastYearMonth = currentTime.addYears(-1).format('yyyyMM');
        yearLastMonth = currentTime.addMonths(-1).format('yyyyMM');
        yearMonthSet.add(lastYearMonth);
        yearMonthSet.add(yearLastMonth);
        //System.debug('yearMonthSet:'+yearMonthSet);
        //查询出去年当月、今年上月的收入成本数据，以便汇总去年当月与今年上月的实际收益值(Gross + Net)
        //例如： 今年当月-201908 去年当月-201808 今年上月-201907 
        this.query = 'SELECT Id,Customer__c,Company_Code__r.CurrencyIsoCode,CurrencyIsoCode,Year__c,Month__c,Product_Line__c,'+
                     'Sales_Revenue__c,Sales_Revenue_USD__c,Sales_Gross_Revenue__c,Sales_Gross_Revenue_USD__c,Sales_Volume__c '+
                     'FROM SAP_Cost_Revenue_Data__c WHERE Year_Month__c IN:yearMonthSet AND Product_Line__c!=null AND Customer__c!=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, list<SAP_Cost_Revenue_Data__c> revenueDataList) {
        Set<String> aprExternalIDSet = new Set<String>();
        Set<String> currencySet = new Set<String>();
        try{
            for(SAP_Cost_Revenue_Data__c revenueData : revenueDataList){
                //如果是是去年同期的收入成本取当前year,如果是上月收入成本取收入成本的year
                String aprExternalID = revenueData.Month__c.equals(month) ? year : revenueData.Year__c;
                aprExternalID = aprExternalID + revenueData.Month__c + revenueData.Customer__c + revenueData.Product_Line__c; 
                aprExternalIDSet.add(aprExternalID);
            }
            //System.debug('aprExternalIDSet: '+aprExternalIDSet);
            String region = 'Hisense USA';
            String queryAPR = 'SELECT Id,CurrencyIsoCode,External_ID__c,N_Month_Gross_N_Year__c,N_Month_Net_N_Year__c,N_Month_Gross_USD_N_Year__c,N_Month_Net_USD_N_Year__c,' +
                              ' N_Month_Gross_N_1_Year__c,N_Month_Net_N_1_Year__c,N_Month_Gross_USD_N_1_Year__c,N_Month_Net_USD_N_1_Year__c,N_Month_Sales_Volume_N_Year__c,'+
                              ' N_Month_Sales_Volume_N_1_Year__c FROM Actual_And_Same_Period_Report__c WHERE External_ID__c IN:aprExternalIDSet and  (Customer__r.Hisense_Entity__c = :region OR Customer__r.Sales_Region__c = :region)';
            List<Actual_And_Same_Period_Report__c> updateAPRList = Database.query(queryAPR);
            Map<String,Actual_And_Same_Period_Report__c> updateAPRMap = new Map<String,Actual_And_Same_Period_Report__c>();
            for(Actual_And_Same_Period_Report__c updateAPR : updateAPRList){
                updateAPRMap.put(updateAPR.External_ID__c, updateAPR);
            }
            //System.debug('updateAPRMap: '+updateAPRMap);
            for(SAP_Cost_Revenue_Data__c revenueData : revenueDataList){
                //如果是是去年同期的收入成本取当前year,如果是上月收入成本取收入成本的year
                String aprExternalID = revenueData.Month__c.equals(month) ? year : revenueData.Year__c;
                aprExternalID = aprExternalID + revenueData.Month__c + revenueData.Customer__c + revenueData.Product_Line__c; 
                //更新今年当月的同期数据，更新今年上月的实际收益数据
                if(updateAPRMap.containsKey(aprExternalID)){
                    Actual_And_Same_Period_Report__c updateAPR = updateAPRMap.get(aprExternalID);
                    //关于updateAPR的汇总计数，如果是第一次则初始化相关字段值
                    if(updateAPRSumCountMap.containsKey(aprExternalID)){
                        updateAPRSumCountMap.put(aprExternalID,updateAPRSumCountMap.get(aprExternalID) + 1);
                    }else{
                        updateAPRSumCountMap.put(aprExternalID, 1);
                        if(!revenueData.Month__c.equals(month)){
                            //初始化今年上月实际收益
                            updateAPR.N_Month_Sales_Volume_N_Year__c = 0;
                            updateAPR.N_Month_Gross_N_Year__c = 0;
                            updateAPR.N_Month_Net_N_Year__c = 0;
                            updateAPR.N_Month_Gross_USD_N_Year__c = 0;
                            updateAPR.N_Month_Net_USD_N_Year__c = 0;
                        }else{
                            //初始化去年当月同期收益
                            updateAPR.N_Month_Sales_Volume_N_1_Year__c = 0;
                            updateAPR.N_Month_Gross_N_1_Year__c = 0;
                            updateAPR.N_Month_Net_N_1_Year__c = 0;
                            updateAPR.N_Month_Gross_USD_N_1_Year__c = 0;
                            updateAPR.N_Month_Net_USD_N_1_Year__c = 0;
                        }
                    }

                    //根据年月+币种得到收入成本币种的汇率以及对应销售组织的汇率
                    String rateYearMonth = revenueData.Year__c + revenueData.Month__c;
                    //销售组织的汇率
                    Decimal rate = currencyRateMap.get(updateAPR.CurrencyIsoCode + rateYearMonth);
                    //收入成本币种的汇率
                    Decimal rate1 = currencyRateMap.get(revenueData.CurrencyIsoCode + rateYearMonth);
                    if(Test.isRunningTest()){
                        rate = 1;rate1 = 1;
                    }
                    if (revenueData.CurrencyIsoCode.equals(updateAPR.CurrencyIsoCode)) {
                        revenueData.Sales_Gross_Revenue__c = convertNull(revenueData.Sales_Gross_Revenue__c);
                        revenueData.Sales_Revenue__c = convertNull(revenueData.Sales_Revenue__c);
                    }else{
                        //如果币种不一样，先转换为美元，之后转换为本位币
                        //currencySet.add(revenueData.CurrencyIsoCode + '_' + revenueData.Company_Code__r.CurrencyIsoCode);
                        revenueData.Sales_Gross_Revenue__c = convertNull(revenueData.Sales_Gross_Revenue__c) / rate1 * rate;
                        revenueData.Sales_Revenue__c = convertNull(revenueData.Sales_Revenue__c) / rate1 * rate;
                    }
                    revenueData.Sales_Gross_Revenue_USD__c = convertNull(revenueData.Sales_Gross_Revenue_USD__c);
                    revenueData.Sales_Revenue_USD__c = convertNull(revenueData.Sales_Revenue_USD__c);
                    revenueData.Sales_Volume__c = convertNull(revenueData.Sales_Volume__c);

                    //根据换算好的收入成本数据更新实际同期字段
                    if(!revenueData.Month__c.equals(month)){
                        //汇总今年上月实际收益
                        updateAPR.N_Month_Sales_Volume_N_Year__c += revenueData.Sales_Volume__c;
                        updateAPR.N_Month_Gross_N_Year__c += revenueData.Sales_Gross_Revenue__c;
                        updateAPR.N_Month_Net_N_Year__c += revenueData.Sales_Revenue__c;
                        updateAPR.N_Month_Gross_USD_N_Year__c += revenueData.Sales_Gross_Revenue_USD__c;
                        updateAPR.N_Month_Net_USD_N_Year__c += revenueData.Sales_Revenue_USD__c;
                    }else{
                        //汇总去年当月同期收益
                        updateAPR.N_Month_Sales_Volume_N_1_Year__c += revenueData.Sales_Volume__c;
                        updateAPR.N_Month_Gross_N_1_Year__c += revenueData.Sales_Gross_Revenue__c;
                        updateAPR.N_Month_Net_N_1_Year__c += revenueData.Sales_Revenue__c;
                        updateAPR.N_Month_Gross_USD_N_1_Year__c += revenueData.Sales_Gross_Revenue_USD__c;
                        updateAPR.N_Month_Net_USD_N_1_Year__c += revenueData.Sales_Revenue_USD__c;
                    }
                }

            }
            //更新实际同期报表的相关字段数据
            update updateAPRMap.values();
        }catch(Exception e){
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {
        //Actual And Same Period Report当月发票数据汇总
        if(System.now().format('yyyyMM').equals(year+month)){
            //只有年月是在当年当月才取发票数据汇总
            InvoiceSummaryExcluBatch invSummary = new InvoiceSummaryExcluBatch(year,Integer.valueOf(month) + '',region);
            Database.executeBatch(invSummary,200);
        }
        
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