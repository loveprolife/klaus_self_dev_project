@isTest
private class PromoterAttendanceHandlerTest {
    static testMethod void testHandler() {
		Promoter_Attendance__c pa = new Promoter_Attendance__c();
		test.startTest();
        INSERT pa;
		test.stopTest();        
    }
}