trigger WhitePriceTrigger on WhitePrice__c (before insert,after insert, before update, after update, before delete, after delete) {
	new WhitePriceTriggerHandler().run();
}