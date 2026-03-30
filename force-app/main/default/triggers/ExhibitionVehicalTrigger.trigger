trigger ExhibitionVehicalTrigger on Exhibition_Vehical_Booking__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionVehicalTriggerHandler().run();
}