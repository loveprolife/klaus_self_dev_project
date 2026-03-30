@isTest
private class GetFobFromGSSProcessBatchTest {
    static testMethod void testMethod1() {

        FOB__c fob = new FOB__c();
        fob.External_Key__c = 'so-sdt';
        fob.Batch_Number__c = 'TEST01';
        insert fob;

        FOB_GSS__c fobGSS = new FOB_GSS__c();
        fobGSS.Batch_Number__c = 'TEST01';
        insert fobGSS;


        GetFobFromGSSProcessBatch fobBatch = new GetFobFromGSSProcessBatch();
        Database.executeBatch(fobBatch,200);

    }

}