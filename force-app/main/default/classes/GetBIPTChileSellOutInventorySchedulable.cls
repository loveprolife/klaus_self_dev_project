global class GetBIPTChileSellOutInventorySchedulable implements Schedulable {
    public String schedulable_name;
    public Date endDate;
    public Date startDate;
    public String numberFlg;
 
    global GetBIPTChileSellOutInventorySchedulable (String schedulable_name, Date startDate, Date endDate){
        this.schedulable_name = schedulable_name;
        this.endDate = endDate;
        this.startDate = startDate;
    }

    global GetBIPTChileSellOutInventorySchedulable (String schedulable_name, String numberFlg){
        this.schedulable_name = schedulable_name;
        this.numberFlg = numberFlg;
    }

    global void execute(SchedulableContext sc) {
        try {

            if(String.isNotBlank(numberFlg)){
                if('1'.equals(numberFlg)){
                    startDate = Date.today().addMonths(-2);
                    endDate = Date.today().addMonths(-1);
                }else if('2'.equals(numberFlg)){
                    startDate = Date.today().addMonths(-1);
                    endDate = Date.today();

                    GetBIPTChileSellOutInventory.GetBIPTChileSellOutInventory(endDate + '');
                }
               
            }
            
            while (startDate < endDate) {
                GetBIPTChileSellOutInventory.GetBIPTChileSellOutInventory(startDate + '');
                startDate = startDate.addDays(1);
            }

            

        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('GetBIPTChileSellOutInventorySchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}