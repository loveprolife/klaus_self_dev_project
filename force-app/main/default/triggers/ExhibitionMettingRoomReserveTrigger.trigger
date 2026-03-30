trigger ExhibitionMettingRoomReserveTrigger on Exhibition_Meeting_Room_Reservation__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionMRRTriggerHander().run();
}