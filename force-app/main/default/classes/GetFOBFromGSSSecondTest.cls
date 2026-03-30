@isTest
private class GetFOBFromGSSSecondTest {

    static testMethod void testMethod1(){
        Test.startTest();
        List<FOB_GSS__c> fobGSSList = new List<FOB_GSS__c>();
        FOB_GSS__c fobGSS = new FOB_GSS__c();
        fobGSS.Batch_Number__c = 'test01';
        insert fobGSS;
        fobGSSList.add(fobGSS);
        GetFOBFromGSSSecond fobGSSProduct = new GetFOBFromGSSSecond(fobGSSList);
        ID jobID = System.enqueueJob(fobGSSProduct);
        Test.stopTest();
    }

}