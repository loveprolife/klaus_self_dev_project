@isTest
private class SendSamplingTargetToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Sampling_Target__c c = new Sampling_Target__c(
            Name = 'YAMADA',
            Region__c = '1',
            SBU__c = '1',
            Customer_Model__c = '1',
            USD__c = '1',
            Sample_Status__c = '出样中',
            Channel__c = '1',
            Total_Sample_Qty_in_2023__c = 2023,
            Total_Sample_Targeted_Qty_in_2024__c = 2024,
            Annual_Target_Achievement_Progress__c = 'pp',
            Targeted_Sample_Numbers_Jan__c = 1,
            Targeted_Sample_Numbers_Feb__c = 2,
            Targeted_Sample_Numbers_Mar__c = 3,
            Targeted_Sample_Numbers_Apr__c = 4,
            Targeted_Sample_Numbers_May__c = 5,
            Targeted_Sample_Numbers_Jun__c = 6,
            Targeted_Sample_Numbers_July__c = 7,
            Targeted_Sample_Numbers_Aug__c = 8,
            Targeted_Sample_Numbers_Sep__c = 9,
            Targeted_Sample_Numbers_Oct__c = 10,
            Targeted_Sample_Numbers_Nov__c = 11,
            Targeted_Sample_Numbers_Dec__c= 12
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2050-02-10 00:00:00"}');
		SendSamplingTargetToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendSamplingTargetToBigData.adoPost();
        Test.stopTest();
    }
}