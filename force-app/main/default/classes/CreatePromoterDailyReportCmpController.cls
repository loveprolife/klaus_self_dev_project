/*
 * @Author: YYL
 * @LastEditors: WFC
 */
public without sharing class CreatePromoterDailyReportCmpController {

    @AuraEnabled
    public static Boolean isPhaseIIIUser(String recordId, String salesRegion) {
        if (recordId!=null) {
            return PhaseIIIUtility.isPhaseIIIData(recordId);
        } else {
            if(String.isNotBlank(salesRegion)){
                return PhaseIIIUtility.isPhaseIIIUserUpdate(salesRegion);
            }else {
                return PhaseIIIUtility.isPhaseIIIUser();
            }
        }
    }

    // 新增校验，判断是进美国加拿大还是其他
    @AuraEnabled
    public static Boolean isPhaseIIIIUser(String recordId, String salesRegion) {
        // 存在日报，根据日报的sales region显示
        if (recordId!=null) {
            return PhaseIIIUtility.isPhaseData(recordId);
        } else {
            // 不存在日报，根据前端选择的sales region
            if(String.isNotBlank(salesRegion)){
                return PhaseIIIUtility.isPhaseUserUpdate(salesRegion);
            }else {
                return PhaseIIIUtility.isPhaseUser();
            }
        }
    }

    @AuraEnabled
    public static String getReportType(String recordId) {
        List<Daily_Inspection_Report__c> reportList = [SELECT Id, Report_Type__c FROM Daily_Inspection_Report__c WHERE Id =:recordId];
        if(reportList != null && reportList.size() > 0){
            return reportList[0].Report_Type__c;
        }else{
            return null;
        }
        
    }

    @AuraEnabled
    public static String getSalesRegion() {
        User userinfo = [SELECT Id, Country__c,Sales_region__c,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];

        return userinfo.Sales_region__c;
    }
}