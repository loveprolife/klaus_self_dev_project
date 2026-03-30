@isTest
private class SendRecordTotalNumberToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendRecordTotalNumberToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendRecordTotalNumberToBigData.adoPost();
        Test.stopTest();
    }
}