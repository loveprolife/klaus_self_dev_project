/*
 * @Author: WFC
 * @Date: 2024-09-11 14:21:53
 * @LastEditors: WFC
 * @LastEditTime: 2024-09-14 16:16:06
 * @Description: SelloutReport报表统计 SelloutReportController.selloutReportStatistics(null);
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\SelloutReportController.cls
 */
public without sharing class SelloutReportController{
    // 汇率
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
    // 数据统计方法
    @InvocableMethod
    public static void selloutReportStatistics(List<String> statisticalDate){
        // 添加数据集合
        List<Sellout_Report__c> upsertList = new List<Sellout_Report__c>();
        // 统计日期
        Date reportDate;
        // 统计日期上个月环比日期
        Date reportDateGrowth;
        // 年
        String yearStr;
        // 月
        String monthStr;
        if (statisticalDate != null && statisticalDate.size() > 0){
            reportDate = Date.valueOf(statisticalDate[0]);
        } else{
            reportDate = Date.today();
        }
        // 统计日期当月一号
        Date reportDateOne = reportDate.toStartOfMonth();
        // 当前日期是否是月底最后一天
        Date reportDateLastDay = reportDate.addMonths(1).toStartOfMonth().addDays(-1);
        // reportDate是当月最后一天，则取上个月最后一天
        if (reportDateLastDay == reportDate){
            reportDateGrowth = reportDate.toStartOfMonth().addDays(-1);
        } else{
            // reportDate日期大于上个月同期日期，则取上个月倒数第二天
            Integer dayInt = reportDate.day();
            Integer lastDayInt = reportDate.toStartOfMonth().addDays(-2).day();
            if (dayInt > lastDayInt){
                reportDateGrowth = reportDate.toStartOfMonth().addDays(-2);
            } else{
                reportDateGrowth = reportDate.addMonths(-1).toStartOfMonth().addDays(dayInt - 1);
            }
        }

        yearStr = reportDate.year() + '';
        monthStr = reportDate.month() + '';
        System.debug('wwwww---reportDate---' + reportDate);
        System.debug('wwwww---yearStr---' + yearStr);
        System.debug('wwwww---monthStr---' + monthStr);
        System.debug('wwwww---reportDateOne---' + reportDateOne);
        System.debug('wwwww---reportDateLastDay---' + reportDateLastDay);
        System.debug('wwwww---reportDateGrowth---' + reportDateGrowth);
        // 获取要统计的user
        List<Sellout_Report_User__c> selloutReportUserList = [SELECT Id, User__c, TV_Key_Model__c, Refrigerator_Key_Model__c
                                                              FROM Sellout_Report_User__c];
        LisqContainer lc = new LisqContainer(selloutReportUserList);
        // user list集合
        List<String> uIdList = lc.SelectSField('User__c');
        // 取要统计的Target数据
        List<SalesGoal__c> salesGoal = [SELECT Id, Amounts__c, CurrencyIsoCode, ResponsiblePerson__r.Principal__c, Store__c, ResponsiblePerson__r.Principal__r.ManagerId
                                        FROM SalesGoal__c
                                        WHERE IsActive__c = true AND Year__c = :yearStr AND Month__c = :monthStr AND ResponsiblePerson__r.Principal__r.ManagerId IN:uIdList AND ProductLine__c = NULL AND RecordType.Name = 'Month'];
        // SalesGoal map集合 uid和list
        Map<String, List<SalesGoal__c>> salesGoalMap = new Map<String, List<SalesGoal__c>>();
        // Target用户门店Set集合
        Set<String> salesGoalShopSet = new Set<String>();
        for (SalesGoal__c sg : salesGoal){
            if (salesGoalMap.containsKey(sg.ResponsiblePerson__r.Principal__r.ManagerId)){
                List<SalesGoal__c> sgList = salesGoalMap.get(sg.ResponsiblePerson__r.Principal__r.ManagerId);
                sgList.add(sg);
                salesGoalMap.put(sg.ResponsiblePerson__r.Principal__r.ManagerId, sgList);
            } else{
                salesGoalMap.put(sg.ResponsiblePerson__r.Principal__r.ManagerId, new List<SalesGoal__c>{ sg });
            }

            salesGoalShopSet.add(sg.ResponsiblePerson__r.Principal__r.ManagerId + '-' + sg.Store__c);
        }

        // 查询dailysales表
        List<Retail_Number__c> dailySalesList = [SELECT Id, CurrencyIsoCode, Shop__c, CreatedBy.ManagerId, TotalPrice__c, Product_Line__c, Product__r.name, ReportDate__c, Number__c
                                                 FROM Retail_Number__c
                                                 WHERE Status__c = 'Submitted' AND ReportDate__c >= :reportDateOne AND ReportDate__c <= :reportDate AND CreatedBy.ManagerId IN:uIdList
                                                 ORDER BY ReportDate__c];
        // dailysales map集合 uid和list

        Map<String, List<Retail_Number__c>> dailySalesMap = new Map<String, List<Retail_Number__c>>();
        for (Retail_Number__c rn : dailySalesList){
            if (dailySalesMap.containsKey(rn.CreatedBy.ManagerId)){
                List<Retail_Number__c> rnList = dailySalesMap.get(rn.CreatedBy.ManagerId);
                rnList.add(rn);
                dailySalesMap.put(rn.CreatedBy.ManagerId, rnList);
            } else{
                dailySalesMap.put(rn.CreatedBy.ManagerId, new List<Retail_Number__c>{ rn });
            }
        }

        // 查询上个月环比数据
        List<Sellout_Report__c> sruList = [SELECT Id, Amount__c, User__c
                                           FROM Sellout_Report__c
                                           WHERE User__c IN:uIdList AND Report_Date__c = :reportDateGrowth];
        LisqContainer sruLC = new LisqContainer(sruList);
        // user list集合
        Map<String, SObject> sruMap = sruLC.ToMapS('User__c');

        // 创建Sellout Report
        for (Sellout_Report_User__c sru : selloutReportUserList){
            Decimal totalTarget = 0;
            Decimal totalAmount = 0;
            Decimal lastMonthAmount = 0;
            Decimal tvMTD = 0;
            Decimal tvDaily = 0;
            Decimal tvKeyModel = 0;
            Decimal refMTD = 0;
            Decimal refDaily = 0;
            Decimal refKeyModel = 0;
            Decimal wmMTD = 0;
            Decimal wmDaily = 0;
            Decimal acMTD = 0;
            Decimal acDaily = 0;
            // 统计Target__c
            List<SalesGoal__c> salesGoalList = salesGoalMap.get(sru.User__c);
            if (salesGoalList != null && salesGoalList.size() > 0){
                for (SalesGoal__c sg : salesGoalList){
                    Decimal rate = currencyRateMap.get(sg.CurrencyIsoCode);
                    totalTarget += sg.Amounts__c / rate;
                }
            }

            // 统计Amount__c
            List<Retail_Number__c> rnList = dailySalesMap.get(sru.User__c);
            if (rnList != null && rnList.size() > 0){
                for (Retail_Number__c rn : rnList){
                    Decimal rate = currencyRateMap.get(rn.CurrencyIsoCode);
                    // 判断dailySales的门店是否在target中
                    if (salesGoalShopSet.contains(rn.CreatedBy.ManagerId + '-' + rn.Shop__c)){
                        totalAmount += rn.TotalPrice__c / rate;
                        // TV 产品线数据
                        if (rn.Product_Line__c == 'TV'){
                            tvMTD += rn.Number__c;
                            // daily 当日数量
                            if (rn.ReportDate__c == reportDate){
                                tvDaily += rn.Number__c;
                            }
                            // 特殊型号
                            if (String.isNotBlank(sru.TV_Key_Model__c) && rn.Product__r.name.toUpperCase().contains(sru.TV_Key_Model__c.toUpperCase())){
                                tvKeyModel += rn.Number__c;
                            }
                        }
                        // Refrigerator 产品线数据
                        if (rn.Product_Line__c == 'Refrigerator'){
                            refMTD += rn.Number__c;
                            // daily 当日数量
                            if (rn.ReportDate__c == reportDate){
                                refDaily += rn.Number__c;
                            }
                            // 特殊型号
                            if (String.isNotBlank(sru.Refrigerator_Key_Model__c) && rn.Product__r.name.toUpperCase().contains(sru.Refrigerator_Key_Model__c.toUpperCase())){
                                refKeyModel += rn.Number__c;
                            }
                        }
                        // WM 产品线数据
                        if (rn.Product_Line__c == 'WM'){
                            wmMTD += rn.Number__c;
                            // daily 当日数量
                            if (rn.ReportDate__c == reportDate){
                                wmDaily += rn.Number__c;
                            }
                        }
                        // AC 产品线数据
                        if (rn.Product_Line__c == 'AC'){
                            acMTD += rn.Number__c;
                            // daily 当日数量
                            if (rn.ReportDate__c == reportDate){
                                acDaily += rn.Number__c;
                            }
                        }
                    }
                }
            }
            if (sruMap.get(sru.User__c) != null){
                Sellout_Report__c sr = (Sellout_Report__c) sruMap.get(sru.User__c);
                lastMonthAmount = sr.Amount__c;
            }

            Sellout_Report__c sr = new Sellout_Report__c();
            sr.CurrencyIsoCode = 'USD';
            sr.User__c = sru.User__c;
            sr.Report_Date__c = reportDate;
            sr.Key__c = sru.User__c + '-' + String.valueOf(reportDate);
            sr.Target__c = totalTarget;
            sr.Amount__c = totalAmount;
            sr.Amount_Last_Month__c = lastMonthAmount;
            sr.TV_MTD__c = tvMTD;
            sr.TV_Daily__c = tvDaily;
            sr.TV_Key_Mode__c = tvKeyModel;
            sr.Refrigerator_MTD__c = refMTD;
            sr.Refrigerator_Daily__c = refDaily;
            sr.Refrigerator_Key_Model__c = refKeyModel;
            sr.WM_MTD__c = wmMTD;
            sr.WM_Daily__c = wmDaily;
            sr.AC_MTD__c = acMTD;
            sr.AC_Daily__c = acDaily;

            upsertList.add(sr);

        }
        Database.upsert (upsertList, Sellout_Report__c.Fields.Key__c, false);

        // 创建Sellout Report & Target中间表
        // List<Sellout_Report_Target__c> srtList = new List<Sellout_Report_Target__c>();
        // for (Sellout_Report__c sr : upsertList){
        //     List<SalesGoal__c> salesGoalList = salesGoalMap.get(sr.User__c);
        //     if (salesGoalList != null){
        //         for (SalesGoal__c sg : salesGoalList){
        //             Sellout_Report_Target__c srt = new Sellout_Report_Target__c();
        //             srt.Sellout_Report__c = sr.Id;
        //             srt.Target__c = sg.Id;
        //             srt.Key__c = sr.Id + '-' + sg.Id;
        //             srt.Target_Amount__c = sg.Amounts__c;
        //             srt.CurrencyIsoCode = sg.CurrencyIsoCode;

        //             srtList.add(srt);
        //         }
        //     }
        // }
        // Database.upsert (srtList, Sellout_Report_Target__c.Fields.Key__c, false);
    }

    // 页面触发
    // @AuraEnabled
    // public static String refreshingData(){
    //     selloutReportStatistics(null);
    //     return 'SUCCESS';
    // }

}