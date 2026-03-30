global class SetThaiActQtyBatchSchedulable implements Schedulable {

    public String schedulable_name;

    global SetThaiActQtyBatchSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
    }


    global void execute(SchedulableContext sc) {
        try {

            // 删除定时任务
            GetThaiSellOutInventorySchedulable.deleteSchedulable(schedulable_name);

            list<Thai_Sell_out_Inventory__c> maxAr= [select create_dt__c from Thai_Sell_out_Inventory__c order by create_dt__c desc limit 1];
            String create_dt = maxAr[0].create_dt__c;

            SetThaiActQtyBatch sqb  = new SetThaiActQtyBatch(create_dt);
		    Database.executeBatch(sqb);

        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('SetThaiActQtyBatchSchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}