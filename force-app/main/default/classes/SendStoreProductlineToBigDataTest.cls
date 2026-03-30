@isTest
private class SendStoreProductlineToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Shop__c ss = new Shop__c();
        ss.Name = 'test';
        Insert ss;
        Store_Product_Line__c s = new Store_Product_Line__c();
        s.Product_Line__c = 'TV';
        s.Store__c = ss.Id;
        Insert s;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2055-02-10 00:00:00"}');
		SendStoreProductlineToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendStoreProductlineToBigData.adoPost();
        Test.stopTest();
    }
}