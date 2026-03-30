global class SAPGetInvoiceLogSchedulable implements Schedulable {

    public List<String> companyCodeList = new List<String>();
    public List<String> orderTypeCodeList = new List<String>();

    global SAPGetInvoiceLogSchedulable (String companyCode, String orderTypeCode){
        this.companyCodeList = companyCode.split(',');
        this.orderTypeCodeList = orderTypeCode.split(',');
    }

    global SAPGetInvoiceLogSchedulable (List<String> companyCodeList, List<String> orderTypeCodeList){
        this.companyCodeList = companyCodeList;
        this.orderTypeCodeList = orderTypeCodeList;
    }

    global void execute(SchedulableContext sc) {
        Date dateToday = System.today()-1;
        String syncStartDate = String.valueOf(dateToday);
        String syncEndDate = String.valueOf(System.today());
        //发票
        SAPGetInvoiceLog.getInvoiceFromSAP(companyCodeList,syncStartDate,syncEndDate,orderTypeCodeList);
    }
}