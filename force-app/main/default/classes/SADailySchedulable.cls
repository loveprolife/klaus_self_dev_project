global without sharing class SADailySchedulable implements Schedulable {
    
    global Void execute(SchedulableContext context) {
        Database.executeBatch(new SchedulingTaskStatusBatch('Hisense South Africa'));
    }
}