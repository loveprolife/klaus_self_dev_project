global class LoginHistorySchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new LoginHistoryBatch(1,'',''),200);
    }
}