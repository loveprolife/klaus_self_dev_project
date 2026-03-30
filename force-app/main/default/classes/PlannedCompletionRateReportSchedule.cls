global class PlannedCompletionRateReportSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
		String day = String.valueOf(System.now().day());
        Database.executeBatch(new PlannedCompletionRateReportBatch(year,month,day),200);
    }
}