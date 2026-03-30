global class GetCustomerInfoFromSAPSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String companyCode = Label.Company_code;
    	List<String> companyCodeList = companyCode.split(',');
    	Date dateToday = System.today()-1;
		String syncStartDate = String.valueOf(dateToday);
		String syncEndDate = String.valueOf(dateToday);
		//do订单
        GetCustomerInfoFromSAP.getCustomerInfo(companyCodeList,syncStartDate,syncEndDate);
    }
}