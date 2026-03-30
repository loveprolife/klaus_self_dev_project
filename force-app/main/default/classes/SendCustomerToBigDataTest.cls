@isTest
private class SendCustomerToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            isGoFinApprove__c = 'fin_approved',
            Basic_Approval_Status__c = 'draft',
            MDG_Customer_Code__c = 'mdg1000000'
        );
        Database.insert(acc1);

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2030-05-10 00:00:00"}');
        SendCustomerToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendCustomerToBigData.adoPost();
        Test.stopTest();
    }
}