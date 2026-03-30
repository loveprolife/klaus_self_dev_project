global without sharing class DeleteRecordBySqlBatch implements Database.Batchable<sObject>{
    global String query;
    global DeleteRecordBySqlBatch(String query){
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> delList){
        Database.delete (delList);
    }

    global void finish(Database.BatchableContext BC){
        Utility.insertLog('DeleteRecordBySqlBatch', '1', this.query, String.valueOf(Datetime.now()));
    }

}