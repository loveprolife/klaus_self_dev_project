@isTest
private class FOBGSSTriggerHandlerTest {

    static testMethod void testMethod1() {
    	Test.startTest();

        FOB_GSS__c fobGSS1 = new FOB_GSS__c();
        fobGSS1.Batch_Number__c = 'batch01';
        fobGSS1.Product_Line_Code__c = '61';
        Database.insert(fobGSS1);
        
        FOB_GSS__c fobGSS2 = new FOB_GSS__c();
        fobGSS2.Batch_Number__c = 'batch02';
        fobGSS2.Product_Line_Code__c = '62';
        Database.insert(fobGSS2);

        FOB_GSS__c fobGSS3 = new FOB_GSS__c();
        fobGSS3.Batch_Number__c = 'batch03';
        fobGSS3.Product_Line_Code__c = '63';
        Database.insert(fobGSS3);

        FOB_GSS__c fobGSS4 = new FOB_GSS__c();
        fobGSS4.Batch_Number__c = 'batch04';
        fobGSS4.Product_Line_Code__c = '64';
        Database.insert(fobGSS4);

        Test.stopTest();
    }

}