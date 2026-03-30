trigger ConsumerTraitResearchTrigger on ConsumerTraitResearch__c (before insert,after insert, before update, after update, before delete, after delete) {
	new ConsumerTraitResearchTriggerHandler().run();
}