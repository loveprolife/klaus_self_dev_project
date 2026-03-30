global class GetFobFromGSSSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new GetFobFromGSSProcessBatch(),200);
    }
}