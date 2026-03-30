trigger ReturnsAndCreditTrigger on ReturnsAndCredit__c (before insert,after insert, before update, after update, before delete, after delete) {
	new ReturnsAndCreditTriggerHandler().run();
}