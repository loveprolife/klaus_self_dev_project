global class QualityCustomerReportBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
		String year = String.valueOf(System.now().year());
		String month = String.valueOf(System.now().month());
        String companyCode = Label.Company_code;
        List<String> companyCodeList = companyCode.split(',');

        //优质客户汇总表
        QualityCustomerReportBatch qcr = new QualityCustomerReportBatch(year,month);
        Database.executeBatch(qcr,200);        
    }
}