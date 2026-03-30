global class OrderShareBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new OrderShareBatch(System.now().addHours(-3),System.now()),200);
    }
}