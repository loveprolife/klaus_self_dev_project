/*
 * @Author: WFC
 * @Date: 2024-03-13 14:47:02
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-16 10:52:32
 * @Description: 样机日报
 PrototypeReportBatch pr = new PrototypeReportBatch();
 Database.executeBatch(pr,200);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\PrototypeReportBatch.cls
 */
global class PrototypeReportBatch implements Database.Batchable<sObject>{
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        List<String> salesRegionList = Label.Asean_Region.split(',');
        this.query = ' SELECT id, Shop__c, CreatedDate, Hidden_Time__c, Product__c, sales_region_f__c, (SELECT Id, Sampling_Detail__c, Display_Time__c, Hidden_Time__c FROM Sampling_Detail_Display_Time__r) ' + 
                 ' FROM Sampling_Detail__c WHERE Shop__r.Sales_Region__c IN :salesRegionList AND Product__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sampling_Detail__c> samplingDetailList){
        // 门店id集合
        Set<Id> shopIdSet = new Set<Id>();
        // 出样Id集合
        Set<Id> samplingDetailIdSet = new Set<Id>();
        // 产品Id集合
        Set<Id> productIdSet = new Set<Id>();
        // 产品Id集合
        Set<String> salesRegionSet = new Set<String>();
        for (Sampling_Detail__c samplingDetail : samplingDetailList){
            shopIdSet.add(samplingDetail.Shop__c);
            samplingDetailIdSet.add(samplingDetail.Id);
            productIdSet.add(samplingDetail.Product__c);
            salesRegionSet.add(samplingDetail.sales_region_f__c);
        }

        // 门店id：负责人 map集合
        Map<Id, String> shopPersonMap = new Map<Id, String>();
        // 查询门店下的负责人
        List<Responsible_Person__c> responsiblePersonList = [SELECT Id, Principal__r.Name, Shop_Name__c
                                                             FROM Responsible_Person__c
                                                             WHERE Shop_Name__c IN:shopIdSet];
        for (Responsible_Person__c rp : responsiblePersonList){
            if (shopPersonMap.containsKey(rp.Shop_Name__c)){
                shopPersonMap.put(rp.Shop_Name__c, shopPersonMap.get(rp.Shop_Name__c) + ',' + rp.Principal__r.Name);
            } else{
                shopPersonMap.put(rp.Shop_Name__c, rp.Principal__r.Name);
            }
        }

        // 查询Price_Rules__c表数据
        List<Price_Rules__c> priceRulesList = [SELECT Id, Product1__c, Sales_Region__c, Start_Date__c, End_Date__c
                                               FROM Price_Rules__c
                                               WHERE Product1__c IN:productIdSet 
                                               AND Sales_Region__c IN:salesRegionSet
                                               ORDER BY Start_Date__c DESC];

        // 样机报表数据
        List<Prototype_Report__c> prototypeReportList = new List<Prototype_Report__c>();
        for (Sampling_Detail__c samplingDetail : samplingDetailList){
            // 计算上架有多少个月
            Integer monthBetween;
            Datetime startDate = samplingDetail.CreatedDate;
            Datetime endDate = System.now();
            Integer startYear = startDate.year();
            Integer startMonth = startDate.month();
            Integer endYear = endDate.year();
            Integer endMonth = endDate.month();
            monthBetween = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;

            if (!samplingDetail.Sampling_Detail_Display_Time__r.isEmpty() && samplingDetail.Sampling_Detail_Display_Time__r != null){
                // 有下架的情况
                List<Sampling_Detail_Display_Time__c> sddtList = samplingDetail.Sampling_Detail_Display_Time__r;
                // 下架有多少个月
                for (Sampling_Detail_Display_Time__c sddt : sddtList){
                    Datetime startDateHidden = sddt.Hidden_Time__c;
                    Datetime endDateHidden = sddt.Display_Time__c != null ? sddt.Display_Time__c : System.now();
                    Integer startYearHidden = startDateHidden.year();
                    Integer startMonthHidden = startDateHidden.month();
                    Integer endYearHidden = endDateHidden.year();
                    Integer endMonthHidden = endDateHidden.month();
                    Integer monthHidden = (endYearHidden - startYearHidden) * 12 + (endMonthHidden - startMonthHidden);
                    // 上下架在同一个月 则不需要统计
                    if (monthHidden == 0){
                        continue;
                    }
                    // 没有下架时间 Display_Time__c == null，则不需要 -1
                    if (sddt.Display_Time__c == null){
                        monthBetween = monthBetween - monthHidden;
                    } else{
                        monthBetween = monthBetween - (monthHidden - 1);
                    }
                }

            }

            // 关联Price_Rules__c表
            List<Price_Rules__c> prList = (List<Price_Rules__c>) new LisqContainer(priceRulesList).WhereAnd(new object[]{
                        'Sales_Region__c', '=', samplingDetail.sales_region_f__c,
                        'Product1__c', '=', samplingDetail.Product__c
                    }).ToSobjectList();

            Prototype_Report__c pr = new Prototype_Report__c();
            pr.Sampling_Detail__c = samplingDetail.id;
            pr.Responsible_Person_Name__c = shopPersonMap.get(samplingDetail.Shop__c);
            pr.Sampling_Month_Total__c = monthBetween;
            if(prList != null && prList.size() > 0){
                pr.Price_Rules__c = prList[0].Id;
            }
           
            prototypeReportList.add(pr);
        }
        insert prototypeReportList;
    }

    global void finish(Database.BatchableContext BC){
        PrototypeReportDailySalesBatch pr = new PrototypeReportDailySalesBatch();
        Database.executeBatch(pr, 100);
    }

}