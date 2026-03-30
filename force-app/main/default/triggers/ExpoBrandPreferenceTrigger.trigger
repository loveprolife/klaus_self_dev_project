trigger ExpoBrandPreferenceTrigger on ExpoBrandPreference__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoBrandPreference__c').run();
}