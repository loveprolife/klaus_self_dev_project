@isTest
private class SendPromoterRevenueToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Promoter_Revenue__c c = new Promoter_Revenue__c(
            Product_Line__c = '1'
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2050-02-10 00:00:00"}');
		SendPromoterRevenueToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendPromoterRevenueToBigData.adoPost();
        Test.stopTest();
    }
}