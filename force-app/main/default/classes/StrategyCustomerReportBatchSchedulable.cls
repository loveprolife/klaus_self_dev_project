global class StrategyCustomerReportBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        String companyCode = Label.Company_code;
        List<String> companyCodeList = companyCode.split(',');

        //战略客户汇总表
        StrategyCustomerReportBatch scr = new StrategyCustomerReportBatch(year,month);
        Database.executeBatch(scr,200);
    }
}