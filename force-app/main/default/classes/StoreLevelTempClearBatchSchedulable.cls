global without sharing class StoreLevelTempClearBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext sc){
        StoreLevelTempClearBatch sltc = new StoreLevelTempClearBatch();
        Database.executeBatch(sltc, 200);
    }

}