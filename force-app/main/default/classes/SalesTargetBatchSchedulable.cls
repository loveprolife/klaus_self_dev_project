global class SalesTargetBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        String companyCode = Label.Company_code;
        List<String> companyCodeList = companyCode.split(',');
        SalesTargetBatch salesTarget = new SalesTargetBatch(year,month);
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
    }
}