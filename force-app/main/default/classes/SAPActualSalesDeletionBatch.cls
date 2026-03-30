global class SAPActualSalesDeletionBatch implements Database.Batchable<sObject> {
    static String yesterdayYear = (Date.today().addDays(-1)+'').substring(0,4);
    static String yesterdayMonth = (Date.today().addDays(-1)+'').substring(5,7);
    static String yesterdayDate = (Date.today().addDays(-1)+'').substring(8,10);
    public List<String> companyCodeList = new List<String>();
    
    
    //static String yesterdayYear = (Date.today()+'').substring(0,4);
    //static String yesterdayMonth = (Date.today()+'').substring(5,7);
    //static String yesterdayDate = (Date.today()+'').substring(8,10);
    global SAPActualSalesDeletionBatch(List<String> companyCodeList) {
        this.companyCodeList = companyCodeList;
        Utility.insertBatchLog('SAPActualSalesDeletionBatch',JSON.serialize(companyCodeList) + ' '+yesterdayYear + yesterdayMonth + yesterdayDate);
    }
    global Database.QueryLocator start(Database.BatchableContext context){
        // return Database.getQueryLocator('Select id from SAP_Sales_Actual__c where Year__c =: yesterdayYear and Month__c =: yesterdayMonth and Date__c =: yesterdayDate and Sales_Orgnization__c in: companyCodeList');
        return Database.getQueryLocator('Select id from SAP_Sales_Actual__c where  Sales_Orgnization__c in: companyCodeList');
    }

    global void execute(Database.BatchableContext context, List<SObject> deletionRecordsList){
        delete deletionRecordsList;
    }
    global void finish(Database.BatchableContext BC) {

    }

}