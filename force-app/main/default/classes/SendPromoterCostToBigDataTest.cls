@isTest
private class SendPromoterCostToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Promoter_Cost__c c = new Promoter_Cost__c(
            Year_Month__c = '1'
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2050-02-10 00:00:00"}');
		SendPromoterCostToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendPromoterCostToBigData.adoPost();
        Test.stopTest();
    }
}