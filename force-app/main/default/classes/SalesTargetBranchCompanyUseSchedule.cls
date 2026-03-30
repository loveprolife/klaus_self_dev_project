global class SalesTargetBranchCompanyUseSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
        Database.executeBatch(new SalesTargetBranchCompanyUseShareBatch(year),200);
    }
}