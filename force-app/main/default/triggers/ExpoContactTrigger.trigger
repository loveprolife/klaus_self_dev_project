trigger ExpoContactTrigger on ExpoContact__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoContact__c').run();
}