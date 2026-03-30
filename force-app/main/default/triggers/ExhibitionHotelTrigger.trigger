trigger ExhibitionHotelTrigger on Hotel_Booked_Info__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionHotelTriggerHandler().run();
}