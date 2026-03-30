trigger ExpoAreaImageTrigger on ExpoAreaImage__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoAreaImage__c').run();
}