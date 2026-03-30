global class SellOutInventoryChileBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SellOutInventoryChileBatch());
    }
}