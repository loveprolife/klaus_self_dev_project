@isTest
private class HopeAttendanceDayTriggerHandlerTest {
    static testMethod void testMethod1() {

        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
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

        Hope_Attendance_Day__c had = new Hope_Attendance_Day__c();
        had.OwnerId = u.id;
        had.Year__c = '2022';
        had.Month__c = '5';

        insert had;
       
    }
}