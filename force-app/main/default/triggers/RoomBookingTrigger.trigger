trigger RoomBookingTrigger on RoomBooking__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // new RoomBookingTriggerHandler().run();
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new RoomBookingTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new RoomBookingTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new RoomBookingTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new RoomBookingTriggerHandler())
	.manage();
}