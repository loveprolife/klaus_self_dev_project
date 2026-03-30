@isTest
private class CommonLookUpControllerTest {
    static testMethod void testMethod1() {
    	Account a1 = new Account();
    	a1.Name = 'test1';
    	insert a1;
    	Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = a1.Id;
        Send_Email_User__c seu1 = new Send_Email_User__c();
        seu1.Username__c = 'test001';
        seu1.Address__c = 'test001@123123.com';
        insert seu1;
        Send_Email_User__c seu2 = new Send_Email_User__c();
        seu2.Username__c = 'test002';
        seu2.Address__c = 'test002@123123.com';
        insert seu2;
        Send_Email__c se = new Send_Email__c();
        se.Address_Ids__c = seu1.id;
        se.Address__c = 'test001@123123.com';
        se.Address_Usernames__c = '<test001> <test001@123123.com>';
        se.Cc__c = seu2.id;
        se.Cc_Ids__c = 'test002@123123.com';
        se.Cc_Usernames__c = '<test002> <test002@123123.com>';
        insert se;
        String seid = se.id;
        String seuid = seu1.id;
        Test.setFixedSearchResults(fixedSearchResults);
    	Test.startTest();
        CommonLookUpController.RetrieveWrapper wrapper = new CommonLookUpController.RetrieveWrapper();
        wrapper.retrieveKeyword = 'test';
        wrapper.searchGroup = 'ALL FIELDS';
        wrapper.objName2FieldMap = new Map<String,String>{'Account'=>'Name','Contact'=>'Name'};
        wrapper.objName2QueryConditionMap = new Map<String,String>{'Account'=>'createddate=TODAY'};
        List<CommonLookUpController.SearchResultWrapper> resultList = CommonLookUpController.search(wrapper);
        system.assertEquals(1, resultList.size());
        CommonLookUpController.SendEmailField sef = new CommonLookUpController.SendEmailField();
        sef.recordId = se.id;
        sef.ids = seu1.id;
        sef.emailAddress = 'test001@123123.com';
        sef.usernameAddress = '<test001> <test001@123123.com>';
        sef.ccIds = seu2.id;
        sef.ccEmailAddress = 'test002@123123.com';
        sef.ccUsernameAddress = '<test002> <test002@123123.com>';
        CommonLookUpController.saveAddress(sef);
        CommonLookUpController.sendEmail(sef);
        CommonLookUpController.saveUser('test003','test003@123123.com');
        CommonLookUpController.searchUserById(seuid);
        CommonLookUpController.searchById(seid);
        Test.stopTest();
    }
}