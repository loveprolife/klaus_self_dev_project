/*
 * @Author: WFC
 * @Date: 2024-01-16 10:17:16
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-17 11:02:32
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventorySubInitializeBatch.cls
 */
global class RealTimeInventorySubInitializeBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventorySubInitializeBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Order__r.Customer__c ,SAP_Product_Customer_Model__c ' + 
                     ' FROM Order_Product__c ' +
                     ' WHERE Order__r.Customer__r.SAP_Customer_Code__c != null ' +
                     ' AND SAP_Product_Customer_Model__c != null ' +
                     ' AND Order__r.Order_Classification__c = \'S\' ' + 
                     ' AND Order__r.Order_Date__c >= :orderDate ' +
                     ' AND Order__r.Customer__r.Sales_Region__c = :salesRegion ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Order_Product__c> orderList) {
        List<Real_Time_Inventory_Sub__c> addList = new List<Real_Time_Inventory_Sub__c>();
        Map<String, String> opMap = new Map<String, String>();
        for(Order_Product__c op : orderList){
            String key = op.Order__r.Customer__c + '-' + op.SAP_Product_Customer_Model__c;
            if(!opMap.containsKey(key)){
                Real_Time_Inventory_Sub__c rtis = new Real_Time_Inventory_Sub__c();
                rtis.Customer__c = op.Order__r.Customer__c;
                rtis.Product_Name__c = op.SAP_Product_Customer_Model__c;
                rtis.Key__c = op.Order__r.Customer__c + '-' + op.SAP_Product_Customer_Model__c;
                addList.add(rtis);
                opMap.put(key, key);
            }
           
        }
        Database.upsert(addList, Real_Time_Inventory_Sub__c.Fields.key__c, false);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventorySubInitializeBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventoryInitializeBatch ss  = new RealTimeInventoryInitializeBatch(this.salesRegion, String.valueOf(this.orderDate));
        Database.executeBatch(ss, 40);
    }
}