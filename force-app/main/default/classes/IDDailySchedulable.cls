global without sharing class IDDailySchedulable implements Schedulable {
    
    global Void execute(SchedulableContext context) {
        Database.executeBatch(new SchedulingTaskStatusBatch('Hisense Indonesia'));
        // LinkedListBatch.executeBatches(new LinkedListBatch[] {
        //     new GeneratePersonalCommissionBatch(),
        //     new GenerateCommonCommissionBatch(),
        //     new CalculateCommissionBatch()
        // });
    }
}