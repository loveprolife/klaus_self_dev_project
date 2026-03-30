trigger ExpoScheduleTrigger on ExpoSchedule__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoSchedule__c').run();
}