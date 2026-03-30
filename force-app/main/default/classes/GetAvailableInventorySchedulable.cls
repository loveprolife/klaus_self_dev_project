global class GetAvailableInventorySchedulable implements Schedulable {
    public String schedulable_name;
 
    global GetAvailableInventorySchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
     }
    global void execute(SchedulableContext sc) {

        try {
            GetAvailableInventoryFromSAP.getAvailableInventoryFromSAP();
            GetAUAvailableInventoryFromSAP.getAUAvailableInventoryFromSAP();
        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('GetAvailableInventorySchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}