trigger ExpoBannerImageTrigger on ExpoBannerImage__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionCalloutHander('ExpoBannerImage__c').run();
}