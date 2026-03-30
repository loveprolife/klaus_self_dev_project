@isTest
private class SyncReminderToPortalTest {
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

        String jobId = System.schedule('SyncReminderToPortalTest','0 5 * * * ? *',new SyncReminderToPortalScheduable());
        
        Account a1 = new Account(Name='Example 2');
        insert a1;

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req2 = 
            new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval.');
        req2.setObjectId(a1.id);

        // Submit on behalf of a specific submitter
        req2.setSubmitterId(u.Id);

        // Submit the record to specific process and skip the criteria evaluation
        req2.setProcessDefinitionNameOrId('Customer_Onboard_HA_Legal_staff');
        req2.setSkipEntryCriteria(true);
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req2);
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req3 = 
            new Approval.ProcessWorkitemRequest();
        req3.setComments('Approving request.');
        req3.setAction('Approve');
        req3.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req3.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req3); 
        System.debug(result2);
        String jobId2 = System.schedule('SyncReminderToPortalTest2','0 5 * * * ? *',new SyncReminderToPortalScheduable());
        Test.stopTest();
   }

}