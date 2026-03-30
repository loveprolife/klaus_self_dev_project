/******************************************************************************
 ************************
 * Name: SyncSampleDisplayFromSAP
 * Description: 定时执行 SyncSampleDisplayFromSAP
 * TestClassName:  SyncSampleDisplayFromSAPSchedulableTest
 * Version History: 0.01
 * Date: 2024-10-29
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
global class SyncSampleDisplayFromSAPSchedulable implements Schedulable {

    public String schedulable_name;

    global SyncSampleDisplayFromSAPSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
    }

    global void execute(SchedulableContext sc) {
        try {
            String zdate = String.valueOf(System.now().addDays(-1)).substring(0, 10).replace('-','');
            SyncSampleDisplayFromSAP.syncSampleDisplayFromSAP(zdate);
            Utility.insertLog('SyncSampleDisplayFromSAPSchedulable', '1', null,  '-----' + schedulable_name);
        } catch (Exception e) {
            Utility.insertLog('SyncSampleDisplayFromSAPSchedulable', '0', null,  '-----' + schedulable_name);
        }
    }
}