@isTest
private class AccountSchedulableTest {
    
    static testmethod void test() {
        Test.startTest();

        Account a = new Account(Name='Example');
        insert a;

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

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(a.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(u.Id);

        req1.setNextApproverIds(new List<String>{u.Id});

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Customer_Onboard_HA_Legal_staff');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result1 = Approval.process(req1);

        // 生成唯一值
        String jobId = System.schedule('SyncReminderToPortalTest','0 5 * * * ? *',new AccountSchedulable(a.Id, 'SyncReminderToPortalTest'));

        Test.stopTest();
    }
 
}