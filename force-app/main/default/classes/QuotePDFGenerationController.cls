public with sharing class QuotePDFGenerationController {
    @AuraEnabled 
    public static Quote__c getQuote(string QuoteId){
        Quote__c quote = [SELECT 	Approval_Status__c FROM Quote__c WHERE id=:QuoteId];
        return quote;
    }   
}