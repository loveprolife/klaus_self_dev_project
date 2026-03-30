global class SAPGetPOOrderSchedulable1 implements Schedulable {
    global void execute(SchedulableContext sc) {
    	String companyCode = Label.Company_Code_For_Oversea;
    	List<String> companyCodeList = companyCode.split(',');
    	for (String str : companyCodeList) {
    		//po订单
    		List<String> companyCodeListRun = new List<String>();
            companyCodeListRun.add(str);
        	SAPGetPOOrder.getPOOrderFromSAP(companyCodeListRun);
    	}
    }
}