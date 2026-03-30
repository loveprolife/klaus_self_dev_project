global class GrowthRateReportBatchShareBatch implements Database.Batchable<sObject> {
    public String query;


    global GrowthRateReportBatchShareBatch() {
       
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Growth_Rate_Report_Obj__c> pcrrList) {
        

    }

    global void finish(Database.BatchableContext BC) {

    }
}