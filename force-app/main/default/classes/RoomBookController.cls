public with sharing class RoomBookController {
    @AuraEnabled(cacheable=true)
    public static List<Expo_Meeting_Booking_Info__c> getRoom() {
            return [
                SELECT
                    Id,
                    Name,
                    capacity__c,
                    Exhibition_Management__c,
                    device__c
                FROM Expo_Meeting_Booking_Info__c
                Where Exhibition_Management__c =: 'a3KTL0000005HY52AM'
            ];
        }
    @AuraEnabled(cacheable=true)
        public static List<Expo_Meeting_Room__c> getBooking() {
            return [
                SELECT
                    Id,
                    Name,
                    note__c,
                    attendees__c,
                    StartTime__c,
                    EndTime__c,
                    Internal_Registration__r.Phone__c,
                    Expo_Meeting_Booking_Info__c,
                    Color__c,
                    logical_delete__c
                FROM Expo_Meeting_Room__c 
                Where Expo_Meeting_Booking_Info__r.Exhibition_Management__c =: 'a3KTL0000005HY52AM' And logical_delete__c <> 'true'
            ];
        }	


}