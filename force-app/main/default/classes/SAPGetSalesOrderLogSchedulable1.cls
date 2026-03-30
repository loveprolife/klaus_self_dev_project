global class SAPGetSalesOrderLogSchedulable1 implements Schedulable {

   public List<String> companyCodeList = new List<String>();
    public List<String> orderTypeCodeList = new List<String>();

    global SAPGetSalesOrderLogSchedulable1 (String companyCode, String orderTypeCode){
        this.companyCodeList = companyCode.split(',');
        this.orderTypeCodeList = orderTypeCode.split(',');
    }

    global SAPGetSalesOrderLogSchedulable1 (List<String> companyCodeList, List<String> orderTypeCodeList){
        this.companyCodeList = companyCodeList;
        this.orderTypeCodeList = orderTypeCodeList;
    }

    global void execute(SchedulableContext sc) {
        Date dateToday = System.today()-1;
        String syncStartDate = String.valueOf(dateToday);
        String syncEndDate = String.valueOf(System.today());
        //发票
        SAPGetSalesOrderLog.getSalesOrderFromSAP(companyCodeList,syncStartDate,syncEndDate,orderTypeCodeList);
    }

}