global class AseanProductSummarySchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AseanProductSummaryBatch(),200);
    }
}