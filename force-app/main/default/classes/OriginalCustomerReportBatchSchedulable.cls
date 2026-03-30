global class OriginalCustomerReportBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        String companyCode = Label.Company_code;
        List<String> companyCodeList = companyCode.split(',');
            
        //原始战略客户汇总表
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch(year,month);
        Database.executeBatch(ocr,200);
    }
}