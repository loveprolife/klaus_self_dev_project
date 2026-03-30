public with sharing class EndCustomerBigScreenCtrl {
    @AuraEnabled
    public static String getReportUrl(String reporId) {
        
            System.debug('reporId==> '+reporId);
            return Call_GenerateExternalPageUrl.generateExternalPageUrl(reporId);
       
    }
    
}