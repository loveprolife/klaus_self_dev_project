global class RevenueStatementReportBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        String companyCode = Label.Company_code;
        List<String> companyCodeList = companyCode.split(',');

        RevenueStatementReportBatch rsr = new RevenueStatementReportBatch(year,month);
        //损益表batch
        Database.executeBatch(rsr,200);
    }
}