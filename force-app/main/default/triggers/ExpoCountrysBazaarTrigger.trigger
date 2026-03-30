trigger ExpoCountrysBazaarTrigger on ExpoCountrysBazaar__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoCountrysBazaar__c').run();
}