trigger MarketInsightTrigger on MarketInsight__c (before insert,after insert, before update, after update, before delete, after delete) {
	new MarketInsightTriggerHandler().run();
}