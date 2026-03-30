trigger StoreViewTrigger on StoreView__c (before insert,after insert, before update, after update, before delete, after delete) {
	new StoreViewTriggerHandler().run();
}