global class SAPActualSalesDelUSAOneBatch implements Database.Batchable<sObject> {

    public List<String> companyCodeList = new List<String>();
    
    global SAPActualSalesDelUSAOneBatch(List<String> companyCodeList) {
        Integer year = Date.today().year();
        Integer month = Date.today().month();
        this.companyCodeList = companyCodeList;
        Utility.insertBatchLog('SAPActualSalesDelUSAOneBatch',JSON.serialize(companyCodeList));
    }
    global Database.QueryLocator start(Database.BatchableContext context){

        return Database.getQueryLocator('Select id from SAP_Sales_Actual__c where Sales_Orgnization__c in: companyCodeList');
    }

    global void execute(Database.BatchableContext context, List<SObject> deletionRecordsList){
        delete deletionRecordsList;
    }
    global void finish(Database.BatchableContext BC) {

    }

}