public with sharing class CLAPrintPDFButtonController {

    @AuraEnabled 
    public static Credit_Limit_Application__c getCreditLimitApplication(string CreditLimitApplicationId) {
        Credit_Limit_Application__c creditLimitApplication = [SELECT Insurance_Company_Approved_Rejected_Comm__c FROM Credit_Limit_Application__c WHERE id=:CreditLimitApplicationId];
        return creditLimitApplication;
    }
}