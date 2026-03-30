trigger MeetingRoomTrigger on Expo_Meeting_Room__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // new RoomBookingTriggerHandler().run();
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new MeetingRoomTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new MeetingRoomTriggerHandler())
    .bind(Triggers.Evt.afterupdate,  new MeetingRoomTriggerHandler())
    .bind(Triggers.Evt.afterinsert,  new MeetingRoomTriggerHandler())
	.manage();
}