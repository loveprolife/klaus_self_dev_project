trigger PromoterShareTrigger on PromoterShare__c (before insert,after insert, before update, after update, before delete, after delete) {
	new PromoterShareTriggerHandler().run();
}