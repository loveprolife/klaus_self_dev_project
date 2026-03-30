global class ActualAndSamePeriodReportSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        Database.executeBatch(new ActualAndSamePeriodReportBatch(year,month),200);
    }
}