@isTest
private class SendChannelItemToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Channel_item__c c = new Channel_item__c(
            Channel_Name__c = 'YAMADA'
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2030-02-10 00:00:00"}');
		SendChannelItemToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendChannelItemToBigData.adoPost();
        Test.stopTest();
    }
}