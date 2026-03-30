global class SAPActualSalesDelUSAOneBatchSchedule implements Schedulable {
    public List<String> companyCodeList = new List<String>();
    global SAPActualSalesDelUSAOneBatchSchedule (List<String> companyCodeList){
        this.companyCodeList = companyCodeList;
        Utility.insertBatchLog('SAPActualSalesDeletionBatchSchedule',JSON.serialize(companyCodeList));
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new SAPActualSalesDelUSAOneBatch(companyCodeList),200);
    }
}