global class SAPGetVirtualOrderSchedulable1 implements Schedulable {
    global void execute(SchedulableContext sc) {
        String companyCode = Label.Company_Code_For_Oversea;
    	List<String> companyCodeList = companyCode.split(',');
    	//虚拟订单
        SAPGetVirtualOrder.getVirtualOrderFromSAP(companyCodeList);
    }
}