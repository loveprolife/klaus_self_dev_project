global class SAPActualSalesDeletionBatchSchedule implements Schedulable {
	public List<String> companyCodeList = new List<String>();
	global SAPActualSalesDeletionBatchSchedule(List<String> companyCodeList){
        this.companyCodeList = companyCodeList;
        Utility.insertBatchLog('SAPActualSalesDeletionBatchSchedule',JSON.serialize(companyCodeList));
	}
    global void execute(SchedulableContext sc) {
     //    String companyCode = Label.Company_code;
    	// List<String> companyCodeList = companyCode.split(',');
        Database.executeBatch(new SAPActualSalesDeletionBatch(companyCodeList),200);
    }
}