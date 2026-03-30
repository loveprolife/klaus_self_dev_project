trigger ExhibitionShuttleBusTrigger on Exhibition_Regular_Bus_Booking__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionShuttleBusTriggerHandler().run();
}