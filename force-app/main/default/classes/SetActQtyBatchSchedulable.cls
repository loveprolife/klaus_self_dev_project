global class SetActQtyBatchSchedulable implements Schedulable {

    public String schedulable_name;

    global SetActQtyBatchSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
    }


    global void execute(SchedulableContext sc) {
        try {

            // 删除定时任务
            GetSellOutInventorySchedulable.deleteSchedulable(schedulable_name);

            list<Sell_out_Inventory__c> maxAr= [select create_dt__c from Sell_out_Inventory__c order by create_dt__c desc limit 1];
            String create_dt = maxAr[0].create_dt__c;

            SetActQtyBatch sqb  = new SetActQtyBatch(create_dt);
		    Database.executeBatch(sqb);

        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('SetActQtyBatchSchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}