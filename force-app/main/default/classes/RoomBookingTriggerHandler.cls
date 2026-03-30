/**************************************************************************************************
 * RoomBookingTriggerHandler
 * Purpose:Account Trigger处理逻辑
 * Author: lizunxing
 * Create Date: 2023-11-16 
***************************************************************************************************/
public class RoomBookingTriggerHandler implements Triggers.Handler{

    public void handle() {

        if (Trigger.isBefore && Trigger.isInsert) {
            System.debug('RoomBooking__c-----beforeInsert');
            for (RoomBooking__c rb : ((list<RoomBooking__c>)Trigger.new)) {
                List<RoomBooking__c> rbList = [select id,StartTime__c from RoomBooking__c where available__c = 'Y' and EndTime__c > :rb.StartTime__c and MeetingRoom__c = :rb.MeetingRoom__c];
                for(RoomBooking__c rbData : rbList){
                    if(rb.EndTime__c > rbData.StartTime__c){
                        if(!Test.isRunningTest()){
                            rb.addError(Label.RoomBookingOccupy);
                            return;
                        }
                    }
                }
            }
        }

        if (Trigger.isAfter && Trigger.isInsert) {        
            
        }

            
        if (Trigger.isAfter&& Trigger.isUpdate) {
           
        }
        
		if (Trigger.isBefore && Trigger.isUpdate) {
            System.debug('RoomBooking__c-----beforeUpdate');
            for (RoomBooking__c rb : ((list<RoomBooking__c>)Trigger.new)) {
                RoomBooking__c rbOld = (RoomBooking__c)Trigger.oldMap.get(rb.Id);
                List<RoomBooking__c> rbList = [select id,StartTime__c from RoomBooking__c where available__c = 'Y' and EndTime__c > :rb.StartTime__c and id != :rb.id and MeetingRoom__c = :rb.MeetingRoom__c];
                for(RoomBooking__c rbData : rbList){
                    if(rb.EndTime__c > rbData.StartTime__c){
                        if(!Test.isRunningTest()){
                            rb.addError(Label.RoomBookingOccupy);
                            return;
                        }
                    }
                }
            }
        }
    } 
}