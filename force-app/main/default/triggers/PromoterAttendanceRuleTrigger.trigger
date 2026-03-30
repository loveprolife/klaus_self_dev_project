trigger PromoterAttendanceRuleTrigger on Promoter_Attendance_Rule__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    new PromoterAttendanceRuleTriggerHandler().run();
}