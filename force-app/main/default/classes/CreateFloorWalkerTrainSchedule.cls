global class CreateFloorWalkerTrainSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CreateFloorWalkerTraining(),2000);
    }
}