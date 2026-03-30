@isTest
public class PromoterAttendanceTriggerTest {
    static testMethod void testTriggerMethod(){
        Promoter_Attendance__c pac = new Promoter_Attendance__c();
        test.startTest();
        INSERT pac;
        test.stopTest();
    }
}