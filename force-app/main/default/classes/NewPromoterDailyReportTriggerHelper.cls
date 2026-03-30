public without sharing class NewPromoterDailyReportTriggerHelper {

    public static void updateCustomerInfo(List<Sobject> oldList, List<Sobject> newList, String shopFieldName){
        updateCustomerInfo(oldList,newList,shopFieldName,'Customer__c');
    }

    public static void updateCustomerInfo(List<Sobject> oldList, List<Sobject> newList, String shopFieldName, String customerFieldName){
        Map<Id, Sobject> oldMap = new Map<Id, Sobject>(oldList);
        LisqContainer lc = new LisqContainer(newList);
        List<String> shopIds = lc.Where1(shopFieldName, 'ISCHANGED', oldList).selectsField(shopFieldName);
        Map<Id,Shop__c> shopMap = new Map<Id,Shop__c>();
        if(shopIds.size() > 0) {
            shopMap = new Map<Id,Shop__c>([
                SELECT 
                    Id,
                    Account__c
                FROM Shop__c
                WHERE Id IN :shopIds
            ]);
        }
        List<String> storeIdList = new List<String>();
        for(Sobject item : newList) {
            // 添加 item.get(shopFieldName) != null 解决三期日报门店可能为空的数据 wfc 2023-12-14
            if(item.get(shopFieldName) != null && shopMap.containsKey(item.get(shopFieldName)+'')) {
                item.put(customerFieldName,shopMap.get(item.get(shopFieldName)+'').Account__c);
            }
        }
    }

    public static void afterSubmit(List<Promoter_Daily_Report__c> oldList, List<Promoter_Daily_Report__c> newList) {
        Map<Id, Promoter_Daily_Report__c> oldMap = new Map<Id, Promoter_Daily_Report__c>(oldList);  
        List<String> submittedReportIdList = new List<String>();
        for(Promoter_Daily_Report__c item : newList) {
            if((oldMap.get(item.Id).Status__c == 'New') && (oldMap.get(item.Id).Status__c != item.Status__c) ) {
                System.debug('NewPromoterDailyReportTriggerHelper ——> afterSubmit');
                submittedReportIdList.add(item.Id);
            }
        }
        if(submittedReportIdList.size() > 0) {
            List<Retail_Number__c> needUpdatedDailySalesList = [SELECT Id, PromoterDailyReport__c, Status__c 
                                                                FROM Retail_Number__c 
                                                                WHERE PromoterDailyReport__c IN :submittedReportIdList AND Status__c != 'Submitted'];
            for(Retail_Number__c item : needUpdatedDailySalesList) {
                System.debug('NewPromoterDailyReportTriggerHelper ——> afterSubmit ——> Retail_Number__c：' + item);
                item.Status__c = 'Submitted';
            }
            if(needUpdatedDailySalesList.size() > 0) {
                update needUpdatedDailySalesList;
            }
        }
    }

    // 发送审批完成的通知
    public static void afterApproved(List<Promoter_Daily_Report__c> oldList, List<Promoter_Daily_Report__c> newList) {
       
        Map<Id, Promoter_Daily_Report__c> oldMap = new Map<Id, Promoter_Daily_Report__c>(oldList);
        String title = System.label.Daily_Report_Of_Notification_Title;
        String body;
        List<CustomNotificationType> cntList = [SELECT id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: 'Custom_Notification'];
        if(cntList.size()>0){
            for(Promoter_Daily_Report__c item : newList) {
                // 当日提交日报自动审批，无需通知
                if(item.ReportSubmittedDelayJudgment__c < 1) {
                    continue;
                }
                if((item.Status__c != oldMap.get(item.Id).Status__c) && ((item.Status__c == 'Approved') || (item.Status__c == 'Rejected'))) {
                    body = item.Name + item.Status__c;
                    Set<String> targetIdList = new Set<String>();
                    targetIdList.add(item.ownerId);
                    Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                    currNotification.setTitle(title);
                    currNotification.setBody(body);
                    currNotification.setNotificationTypeId(cntList[0].Id);
                    currNotification.setTargetId(item.Id);

                    currNotification.send(targetIdList);
                }
            }
        }

    }

}