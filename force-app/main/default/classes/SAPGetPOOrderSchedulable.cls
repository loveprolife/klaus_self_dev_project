global class SAPGetPOOrderSchedulable implements Schedulable {
    public List<String> companyCodeList = new List<String>();
    global SAPGetPOOrderSchedulable(List<String> companyCodeList){
        this.companyCodeList = companyCodeList;
    }
    global void execute(SchedulableContext sc) {
        SAPGetPOOrder.getPOOrderFromSAP(companyCodeList);
    	//String companyCode = Label.Company_Code3;
    	//List<String> companyCodeList = companyCode.split(',');
    	// for (String str : companyCodeList) {
    	// 	List<String> companyCodeListRun = new List<String>();
    	// 	companyCodeListRun.add(str);
    	// 	//po订单
     //    	SAPGetPOOrder.getPOOrderFromSAP(companyCodeListRun);
    	// }
    }
}