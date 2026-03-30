public with sharing class CustomerVisitPrintPDFButtonController {

	@AuraEnabled 
    public static Customer_Visit__c getCustomerVisit(string CustomerVisitId) {
        System.debug('www111--' + CustomerVisitId);
        Customer_Visit__c customerVisit = [SELECT Problems_to_be_solved_by_Hisense__c FROM Customer_Visit__c WHERE id=:CustomerVisitId];
        return customerVisit;
    }

    @AuraEnabled 
    public static Customer_Visit_Detail__c getVisitDetail(string CustomerVisitId) {
        System.debug('www2222--' + CustomerVisitId);
        Customer_Visit_Detail__c visitDetail = [SELECT Id,Attend_From_Customer__c, Attend_From_Hisense__c,Meetting_Topic__c, Meetting_Method__c, Representative_From_Customer__c, Representative_From_Hisense__c, Date_Time__c  FROM Customer_Visit_Detail__c WHERE Customer_Visit_Lookup__c=:CustomerVisitId  order by CreatedDate DESC limit 1];
        return visitDetail;
    }
}