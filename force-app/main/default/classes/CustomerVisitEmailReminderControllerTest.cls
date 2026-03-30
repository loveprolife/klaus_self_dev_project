@isTest
private class CustomerVisitEmailReminderControllerTest {
    static testMethod void testMethod1() {
        Test.startTest();
        CustomerVisitEmailReminderController.sendEmailReminder(null);
        Test.stopTest();

    }
}