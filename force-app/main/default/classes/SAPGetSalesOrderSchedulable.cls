global class SAPGetSalesOrderSchedulable implements Schedulable {
    public List<String> companyCodeList = new List<String>();
    public List<String> orderTypeCodeList = new List<String>();
    global SAPGetSalesOrderSchedulable(List<String> companyCodeList,List<String> orderTypeCodeList){
        this.companyCodeList = companyCodeList;
        this.orderTypeCodeList = orderTypeCodeList;
    }
    global void execute(SchedulableContext sc) {
        Date dateToday = System.today()-1;
        String syncStartDate = String.valueOf(dateToday);
        String syncEndDate = String.valueOf(System.today());
        //SAPGetInvoice.getInvoiceFromSAP(companyCodeList,syncStartDate,syncEndDate);
        for (String str : companyCodeList) {
            List<String> companyCodeListRun = new List<String>();
            companyCodeListRun.add(str);
            for (String str1 : orderTypeCodeList) {
                List<String> orderTypeCodeListRun = new List<String>();
                orderTypeCodeListRun.add(str1);
                //发票
                SAPGetSalesOrder.getSalesOrderFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }
      }
    }
}