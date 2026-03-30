@isTest
private class SendSamplingConditionToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Sampling_Condition__c c = new Sampling_Condition__c(
            // Name = 'YAMADA',
            Region__c = '1',
            SBU__c = '1',
            Channel_Code__c = '1',
            Customer_Model__c = '1',
            USD__c = '1',
            Sampling_Status__c = '出样中',
            Actual_Sample_Qty__c = '1',
            Channel__c = '1',
            Date__c = System.today()
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2050-02-10 00:00:00"}');
		SendSamplingConditionToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendSamplingConditionToBigData.adoPost();
        Test.stopTest();
    }
}