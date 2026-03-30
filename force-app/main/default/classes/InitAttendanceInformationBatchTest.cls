@isTest
private class InitAttendanceInformationBatchTest {
    static testMethod void testMethod1() {

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = '促销员'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        Profile p1 = [SELECT Id,Name FROM Profile WHERE Name = '巡店员'];

        User user2 = new User(
            Alias = 'admin1', Email='systemadmin1@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p1.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin1@hisensetest.com'
        );
        Database.insert(user2);

        Hope_Attendance_Day__c had = new Hope_Attendance_Day__c();
        had.Year__c = '2022';
        had.Month__c = '1';
        had.OwnerId = user1.id;
        had.X1__c = true;
        had.X2__c = false;
        Database.insert(had);

        Hope_Attendance_Day__c had1 = new Hope_Attendance_Day__c();
        had1.Year__c = '2022';
        had1.Month__c = '1';
        had1.OwnerId = user2.id;
        had1.X1__c = false;
        had1.X2__c = true;
        Database.insert(had1);

        Database.executeBatch(new InitAttendanceInformationBatch('2022-01-01'),200);
    }
}