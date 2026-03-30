@isTest
private class SendProductToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Product__c productTest = new Product__c();
        productTest.Name = 'NTC-33K';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'DELOITTE';
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Insert productTest;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2030-02-10 00:00:00"}');
		SendProductToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendProductToBigData.adoPost();
        Test.stopTest();
    }
}