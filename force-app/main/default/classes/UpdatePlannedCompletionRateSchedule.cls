global class UpdatePlannedCompletionRateSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer iyear = System.now().year();
        Integer imonth = System.now().month();
        
        if(imonth == 1){
            imonth = 12;
            iyear -= 1;
        } else {
            imonth -= 1;
        }
        String year = String.valueOf(iyear);
        String month = String.valueOf(imonth);
        Database.executeBatch(new UpdatePlannedCompletionRateBatch(year,month),200);
    }
}