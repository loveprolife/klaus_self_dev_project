global class DeletePlannedCompletionRateSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        Database.executeBatch(new DeletePlannedCompletionRateReportBatch(year,month),200);
    }
}