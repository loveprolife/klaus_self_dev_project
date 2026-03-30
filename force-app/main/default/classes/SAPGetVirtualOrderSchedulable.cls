global class SAPGetVirtualOrderSchedulable implements Schedulable {
	public List<String> companyCodeList = new List<String>();
    global SAPGetVirtualOrderSchedulable(List<String> companyCodeList){
        this.companyCodeList = companyCodeList;
    }
    global void execute(SchedulableContext sc) {
     //    String companyCode = Label.Company_Code3;
    	// List<String> companyCodeList = companyCode.split(',');
    	//虚拟订单
        SAPGetVirtualOrder.getVirtualOrderFromSAP(companyCodeList);
    }
}