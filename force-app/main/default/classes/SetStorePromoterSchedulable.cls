/******************************************************************************
 ************************
 * Name: SyncSampleDisplayFromSAP
 * Description: 定时执行 SetStorePromoterBatch
 * TestClassName:  SetStorePromoterSchedulableTest
 * Version History: 0.01
 * Date: 2025-01-07
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
global class SetStorePromoterSchedulable implements Schedulable {

    public String schedulable_name;

    global SetStorePromoterSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
    }

    global void execute(SchedulableContext sc) {
        try {
            SetStorePromoterBatch ss = new SetStorePromoterBatch();
		    Database.executeBatch(ss, 150);
            Utility.insertLog('SetStorePromoterSchedulable', '1', null,  '-----' + schedulable_name);
        } catch (Exception e) {
            Utility.insertLog('SetStorePromoterSchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}