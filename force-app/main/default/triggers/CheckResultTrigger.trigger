trigger CheckResultTrigger on CheckResult__c (before insert, after insert, before update, after update, before delete, after delete) {
	new CheckResultTriggerHandler().run();
}