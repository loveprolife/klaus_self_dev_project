global class GetMakroChannelSchedulable implements Schedulable {
    public String schedulable_name;
 
    global GetMakroChannelSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
     }
    global void execute(SchedulableContext sc) {
        Datetime d = System.now().addHours(8);
        try {
            GetMakroChannelInventory.GetMakroChannelInventory(d);
            GetMakroChannelAllSalesDetail.GetMakroChannelAllSalesDetail(d);
            GetMakroChannelECSalesDetail.GetMakroChannelECSalesDetail(d);
        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('GetMakroChannelSchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}