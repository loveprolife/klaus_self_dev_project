global class CustomerVolumeRevenueReportSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        String companyCode = Label.Company_code;
        List<String> companyCodeList = companyCode.split(',');

        //战略客户汇总表
        CustomerVolumeRevenueReportBatch cvrr = new CustomerVolumeRevenueReportBatch(year,month);
        Database.executeBatch(cvrr,200);
    }
}