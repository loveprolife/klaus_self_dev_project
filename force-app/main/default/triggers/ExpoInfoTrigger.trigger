trigger ExpoInfoTrigger on ExpoInfo__c(before insert,after insert, before update, after update, before delete, after delete) {
     new ExhibitionCalloutHander('ExpoInfo__c').run();
}