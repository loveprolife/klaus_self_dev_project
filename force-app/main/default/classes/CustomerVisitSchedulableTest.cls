@isTest
private class CustomerVisitSchedulableTest {
    
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

        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'test001';
        cv.Customer__c = a.id;
        cv.Visit_Category__c = '';
        cv.Visit_Date__c = Date.today();
        cv.Sales_Expected_Remind_Date__c = Date.today();
        cv.Place__c = '';
        cv.Visit_Purpose__c = '';
        cv.Status__c = '';
        cv.Achivement__c = '';
        cv.Visit_Matter__c = '';
        cv.Meeting_Minutes__c = '';
        Database.insert(cv);

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(cv.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(u.Id);

        req1.setNextApproverIds(new List<String>{u.Id});

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Customer_Visit_for_SA');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result1 = Approval.process(req1);

        // 生成唯一值
        String jobId = System.schedule('SyncReminderToPortalTest','0 5 * * * ? *',new CustomerVisitSchedulable(a.Id, 'SyncReminderToPortalTest'));

        Test.stopTest();
    }
 
}