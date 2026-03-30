trigger SalesGoalTrigger on SalesGoal__c (before insert,after insert, before update, after update, before delete, after delete) {
	new SalesGoalTriggerHandler().run();
}