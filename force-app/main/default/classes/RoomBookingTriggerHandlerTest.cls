@isTest
private class RoomBookingTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();

        RoomBooking__c rb = new RoomBooking__c();
        rb.available__c = 'Y';
        rb.StartTime__c = System.now();
        rb.Detail__c = '111';
        rb.Subject__c = '111';
        rb.EndTime__c = System.now().addHours(1);

        MeetingRoom__c mr = new MeetingRoom__c();
        mr.name = '123';
        Database.insert(mr);

        rb.MeetingRoom__c = mr.id;
        Database.insert(rb);

        RoomBooking__c rb1 = new RoomBooking__c();
        rb1.available__c = 'Y';
        rb1.StartTime__c = System.now();
        rb.Detail__c = '111';
        rb1.Subject__c = '111';
        rb1.EndTime__c = System.now().addMinutes(30);
        rb1.MeetingRoom__c = mr.id;
        Database.insert(rb1);

        rb.Detail__c = '222';
        Database.update(rb);

        Test.stopTest();
    }
}