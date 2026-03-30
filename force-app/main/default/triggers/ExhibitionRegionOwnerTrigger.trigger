trigger ExhibitionRegionOwnerTrigger on Exhibition_Region_Owner__c (before insert,after insert, before update, after update, before delete, after delete) {
	new ExhibitionRegionHandler().run();
}