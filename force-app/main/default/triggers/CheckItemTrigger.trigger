trigger CheckItemTrigger on CheckItem__c (before insert,after insert, before update, after update, before delete, after delete) {
	new CheckItemTriggerHandler().run();
}