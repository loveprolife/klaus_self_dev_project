global without sharing class StoreInspectionReportBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext sc){
        StoreInspectionReportBatch sir = new StoreInspectionReportBatch();
        Database.executeBatch(sir, 200);
    }

}