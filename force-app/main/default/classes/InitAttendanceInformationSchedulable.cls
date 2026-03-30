public class InitAttendanceInformationSchedulable implements Schedulable{

    public void execute(SchedulableContext sc){
        String thisDay = String.valueOf(System.today());
        Database.executeBatch(new InitAttendanceInformationBatch(thisDay),200);
    }

}