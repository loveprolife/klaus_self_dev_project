@isTest
private class ApprovalRecordHistoryBatchTest {
    
    static testmethod void test() {
        Test.startTest();

        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
        u.username = 'ApprovalRecordHistoryBatch@salesforce.com';
        u.email = 'ApprovalRecordHistoryBatch@salesforce.com';
        u.lastName = 'HisenseSSORegHandlerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        insert u;

        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        PickList__c pickList = new PickList__c();
        pickList.Name = 'United States of America (USA)';
        pickList.Value__c = 'USA';
        pickList.ex_id__c = 'USA';
        pickList.belong_to_RR_Country__c = 'United States of America (USA)';
        pickList.RecordTypeId = Schema.SObjectType.PickList__c.getRecordTypeInfosByName().get('Master Data(RR Country)').getRecordTypeId();
        Database.insert(pickList);
        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Customer__c = accId;
        creditLimit.Payment_Method__c = '1';
        creditLimit.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit.Buyer_Country_Code__c = pickList.Id;
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit);

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(creditLimit.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(u.Id);

        req1.setNextApproverIds(new List<String>{u.Id});

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Credit_Application_NonLC_SD1_SM_HePiLin');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result1 = Approval.process(req1);

        Database.executeBatch(new ApprovalRecordHistoryBatch('SELECT ID FROM Credit_Limit_Application__c WHERE ID = ' + '\'' + creditLimit.Id + '\''));

        Test.stopTest();
    }
 
}