trigger ExpoHisImageTrigger on ExpoHisImage__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoHisImage__c').run();
}