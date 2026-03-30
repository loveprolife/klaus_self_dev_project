trigger ExpoProductPreferenceTrigger on ExpoProductPreference__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoProductPreference__c').run();
}