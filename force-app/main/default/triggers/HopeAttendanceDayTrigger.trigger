trigger HopeAttendanceDayTrigger on Hope_Attendance_Day__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new HopeAttendanceDayTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new HopeAttendanceDayTriggerHandler())
    .manage();
}