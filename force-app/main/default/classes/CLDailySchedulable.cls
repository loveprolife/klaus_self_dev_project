global without sharing class CLDailySchedulable implements Schedulable {
    
    global Void execute(SchedulableContext context) {
        Database.executeBatch(new SchedulingTaskStatusBatch('Hisense Chile'));
    }
}