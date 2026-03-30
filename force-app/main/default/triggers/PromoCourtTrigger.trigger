trigger PromoCourtTrigger on PromoCourt__c (before insert,after insert, before update, after update, before delete, after delete) {
	new PromoCourtTriggerHandler().run();
}