/**********************************************************************
 * Name: GSSInventoryReportShare
 * Object: GSSInventoryReport
 * Purpose:
 * GSSInventoryReport share权限
 * Create Date: 2019-10-21
 * GSS_Inventory_Report__c
 * GSSInventoryReportData
 *************************************************************************/
global class GSSInventoryReportShareBatch implements Database.Batchable<sObject> {

	public String query;
	public String year;
	public String month;

/*
   global GSSInventoryReportShareBatch(String year,String month) {
    this.year = year;
    this.month = month;
    this.query = 'SELECT Id,Customer__c,Product_Line__c,OwnerId FROM Revenue_Statement_Report__c WHERE Product_Line__c != null AND Customer__c !=null AND Year__c =:year and Month__c =:month';
   }
 */
global GSSInventoryReportShareBatch() {
	//this.year = year;
	//this.month = month;
	this.query = 'SELECT Id,Customer__c,ProductLineText__c,OwnerId FROM GSS_Inventory_Report__c WHERE ProductLineText__c != null AND Customer__c !=null';
}

global Database.QueryLocator start(Database.BatchableContext bc) {
	return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, list<GSS_Inventory_Report__c> orderList) {
	Set<Id> cusIdSet = new Set<Id>();
	Set<Id> orderIdSet = new Set<Id>();

	for (GSS_Inventory_Report__c orderData : orderList) {
		orderIdSet.add(orderData.Id);
		cusIdSet.add(orderData.Customer__c);
	}

	List<Sales__c> salesList = [SELECT id, Customer__c, Sales__c, Sales__r.IsActive,IsKeyUser__c, Product_Line__c FROM Sales__c WHERE Customer__c IN : cusIdSet AND Sales__r.IsActive = TRUE];
	Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
	for (Sales__c salesData : salesList) {
		if(salesMap.containsKey(salesData.Customer__c)){
			salesMap.get(salesData.Customer__c).add(salesData);
		}else{
			salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
		}
	}

	List<GSS_Inventory_Report__Share> insertOrderShareList = new List<GSS_Inventory_Report__Share>();

	//设置Share
	Map<String, GSS_Inventory_Report__Share> insertOrderMap = new Map<String, GSS_Inventory_Report__Share>();
	List<GSS_Inventory_Report__c> updateOrderList = new List<GSS_Inventory_Report__c>();//需要更新记录
	for (GSS_Inventory_Report__c orderData : orderList) {
		
		Boolean flag = false;
		List<Sales__c> salescList = salesMap.get(orderData.Customer__c);
		List<Sales__c> productLineSalesList = new List<Sales__c>();
		if (salescList == null) {
			continue;
		}
		
		for (Sales__c salesme : salescList) {
			// if (orderData.OwnerId != salesme.Sales__c) {
			//     if(accessUserMap.containsKey(orderData.Id) && accessUserMap.get(orderData.Id).contains(salesme.Sales__c)){
			//         continue;
			//     }
			// }
			if (Utility.isExistProductLine(orderData.ProductLineText__c, salesme.Product_Line__c)) {
				//设置owner则不设置share
				GSS_Inventory_Report__Share orderShareData = new GSS_Inventory_Report__Share();
				orderShareData.RowCause = 'Manual';
				orderShareData.ParentId = orderData.Id;
				orderShareData.UserOrGroupId  = salesme.Sales__c;
				orderShareData.AccessLevel = 'Read';
				String idKeyString = String.valueOf(orderData.Id)+String.valueOf(salesme.Sales__c);
				insertOrderMap.put(idKeyString, orderShareData);
				productLineSalesList.add(salesme);
				// //如果为keyuser，设置为owner
				// if (salesme.IsKeyUser__c 
				// && !orderData.OwnerId.equals(salesme.Sales__c)) {
				// 	orderData.OwnerId = salesme.Sales__c;
				// 	updateOrderList.add(orderData);
				// 	flag = true;
				// }
			}
		}
		// if (flag == false 
		// 	&& productLineSalesList.size() > 0
		// 	&& !orderData.OwnerId.equals(productLineSalesList[0].Sales__c)) {
		// 	orderData.OwnerId = productLineSalesList[0].Sales__c;
		// 	updateOrderList.add(orderData);
		// }
		// String mapString = String.valueOf(orderData.Id)+String.valueOf(orderData.OwnerId);
		// if (insertOrderMap.containsKey(mapString)) {
		// 	insertOrderMap.remove(mapString);
		// }
	}

	if(insertOrderMap.size() > 0){
		insertOrderShareList = insertOrderMap.values();
		try{
			Database.upsert(insertOrderShareList);
		}catch(Exception e){
			system.debug('error message'+e.getMessage());
			system.debug('line number'+e.getLineNumber());
		}
	}
}

	global void finish(Database.BatchableContext BC) {

	}
}