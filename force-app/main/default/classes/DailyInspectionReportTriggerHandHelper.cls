/*
 * @Author: Su,Tiger Shanhu
 * @Date: 2023-06-28 11:30:31
 * @LastEditors: WFC
 * @LastEditTime: 2025-07-28 13:48:07
 * @Description: 
 */
public with sharing class DailyInspectionReportTriggerHandHelper {
    
    public static void submitCheckAns(List<Daily_Inspection_Report__c> newList,List<Daily_Inspection_Report__c> oldList) {
        List<String> changeIdList = new LisqContainer(newList).WhereOne('Status__c','IsChanged',oldList).WhereOne('Status__c','=','Submitted')
        .SelectField('Id').ToS();
        List<CheckResult__c> upsertList = new List<CheckResult__c>();
        // for (CheckResult__c result : [select Id,PromoterDailyReport__c ,Status__c from CheckResult__c WHERE Status__c = 'Draft' and  PromoterDailyReport__c =:changeIdList]) {
        for (CheckResult__c result : [select Id,PromoterDailyReport__c ,Status__c from CheckResult__c WHERE Status__c = 'Draft' and  InspectorDailyReport__c =:changeIdList]) {
            result.Status__c = 'Submitted';
            upsertList.add(result);
        }
        if (upsertList.size()>0) {
            update upsertList;
        }
    }
    public static void upsertExternalId(){
        for (Daily_Inspection_Report__c  dirItem : (List<Daily_Inspection_Report__c >)Trigger.new) {
            dirItem.ExternalId__c = dirItem.Store__c + '_' + dirItem.OwnerId + '_' + dirItem.Report_Date__c;
        }
    }
}