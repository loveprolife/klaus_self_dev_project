trigger ShopRetailDetailTrigger on Shop_Retail_Detail__c (before insert,after insert, before update, after update, before delete, after delete) {
	new ShopRetailDetailTriggerHandler().run();
}