@isTest
private class SendCustomerManagementToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Customer_Management__c c = new Customer_Management__c();
        c.Name = 'Test';
        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2050-02-10 00:00:00"}');
		SendCustomerManagementToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendCustomerManagementToBigData.adoPost();
        Test.stopTest();
    }
}