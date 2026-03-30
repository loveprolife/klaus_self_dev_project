global class RevenueCostSummarySchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        Database.executeBatch(new RevenueCostSummaryBatch(year,month),200);
    }
}