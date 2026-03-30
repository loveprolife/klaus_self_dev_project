@isTest
private class UserControllerTest {
    
    static testMethod void testMethod1() {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        User user1 = new User(
            Alias = 'test01', Email='test-0-01@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='test-0-01@hisensetest.com'
        );
        Database.insert(user1);

        List<String> userEmailList = new List<String>();
        userEmailList.add('test-001@test001.com');
        userEmailList.add('test-0-01@hisensetest.com');

        Send_Email_User__c seu1 = new Send_Email_User__c();
        seu1.Username__c = 'test-0-01';
        seu1.Address__c = 'test-001@test001.com';
        insert seu1;

        Send_Email_User__c seu2 = new Send_Email_User__c();
        seu2.Username__c = 'test-0-02';
        seu2.Address__c = 'test-0-01@hisensetest.com';
        insert seu2;

    	Test.startTest();
        UserController.insertUser(userEmailList);
        Test.stopTest();
    }
}