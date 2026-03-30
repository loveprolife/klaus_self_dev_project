trigger CheckListScopeTrigger on CheckListScope__c (before insert,after insert, before update, after update, before delete, after delete) {
	new CheckListScopeTriggerHandler().run();
}