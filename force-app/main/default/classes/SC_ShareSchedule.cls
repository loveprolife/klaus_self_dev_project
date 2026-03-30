global class SC_ShareSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        try{
            Id batchInstanceId = Database.executeBatch(new SC_OrderShareBatch());
        }catch(Exception e){
            system.debug('SC_OrderShareBatch ==:'+e.getMessage());
        } 
    }
}