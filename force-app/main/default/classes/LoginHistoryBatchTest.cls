@isTest
private class LoginHistoryBatchTest {
    static testMethod void testMethod1() {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);
        // LoginHistoryBatch ss  = new LoginHistoryBatch(1);
        // Database.executeBatch(ss);
    }
}