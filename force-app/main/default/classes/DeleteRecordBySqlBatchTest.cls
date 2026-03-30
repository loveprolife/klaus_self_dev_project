@isTest
public with sharing class DeleteRecordBySqlBatchTest{
    static testMethod void testMethod1(){
        FOB__c fob = new FOB__c();
        fob.External_Key__c = 'so-sdt';
        fob.Batch_Number__c = 'TEST01';
        insert fob;

        DeleteRecordBySqlBatch drbb = new DeleteRecordBySqlBatch('SELECT Id FROM FOB__c');
        Database.executeBatch(drbb, 200);
    }

}