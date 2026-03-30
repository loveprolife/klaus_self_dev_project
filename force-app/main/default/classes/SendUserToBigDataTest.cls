@isTest
private class SendUserToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
        u.username = 'HisenseSSORegHandlerTest@salesforce.com';
        u.email = 'HisenseSSORegHandlerTest@salesforce.com';
        u.lastName = 'HisenseSSORegHandlerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.HisenseSSOName__c = 'testId';
        insert u;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendUserToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendUserToBigData.adoPost();
        Test.stopTest();
    }
}