/*
 * @Author: WFC
 * @Date: 2023-08-30 10:40:27
 * @LastEditors: WFC
 * @LastEditTime: 2023-11-28 15:28:18
 * @Description: CustomerOrderInventoryBatch ss  = new CustomerOrderInventoryBatch('8110', '2023-01-01');
		Database.executeBatch(ss);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\CustomerOrderInventoryBatch.cls
 */
global class CustomerOrderInventoryBatch implements Database.Batchable<sObject> {
    public String query;
    public Date orderDate;
    public String entity;

    global CustomerOrderInventoryBatch(String entity, String orderDate) {
        this.entity = entity;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Order__r.Customer__c, Order__r.Customer__r.SAP_Customer_Code__c, Product_Line__c,  SAP_Product_Customer_Model__c, Quantity__c ' + 
                     ' FROM Order_Product__c ' +
                     ' WHERE Order__r.Customer__r.SAP_Customer_Code__c != null ' +
                     ' AND SAP_Product_Customer_Model__c != null ' +
                     ' AND Product_Line__c != null ' +
                     ' AND Order__r.Order_Classification__c = \'S\' ' + 
                     ' AND Order__r.Order_Date__c >= :orderDate ' +
                     ' AND Hisense_Entity__c = :entity ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order_Product__c> orderProductList) {
        Set<String> keySet = new Set<String>();
        for(Order_Product__c op : orderProductList){
            String customer = op.Order__r.Customer__c;
            String sapCustomerCode =  op.Order__r.Customer__r.SAP_Customer_Code__c;
            String productLine = op.Product_Line__c;
            String product =  op.SAP_Product_Customer_Model__c;
            keySet.add(sapCustomerCode + '-' + productLine + '-' + product);
        }
        // 客户订单库存表集合
        List<Customer_Order_Inventory__c> coiList = [SELECT id, key__c, Quantity__c FROM Customer_Order_Inventory__c WHERE key__c IN:keySet];
        // 客户订单库存表map
        Map<String, Customer_Order_Inventory__c> keyMap = new Map<String, Customer_Order_Inventory__c>();
        for (Customer_Order_Inventory__c coi : coiList) {
            keyMap.put(coi.key__c, coi);
        }

        for(Order_Product__c op : orderProductList){
            Decimal quantity = op.Quantity__c;
            String customer = op.Order__r.Customer__c;
            String sapCustomerCode =  op.Order__r.Customer__r.SAP_Customer_Code__c;
            String productLine = op.Product_Line__c;
            String product =  op.SAP_Product_Customer_Model__c;
            String key = sapCustomerCode + '-' + productLine + '-' + product;

            if(keyMap.containsKey(key)){
                keyMap.get(key).Quantity__c = keyMap.get(key).Quantity__c + quantity;
                keyMap.get(key).Is_Sync__c = true;
            }else {
                Customer_Order_Inventory__c coi = new Customer_Order_Inventory__c();
                coi.key__c = key;
                coi.Customer__c = customer;
                coi.SAP_Customer_Code__c = sapCustomerCode;
                coi.Product_Line__c = productLine;
                coi.Product__c = product;
                coi.Entity__c = this.entity;
                coi.Quantity__c = quantity;
                coi.Is_Sync__c = true;
                keyMap.put(key, coi);
            }
        }
        Database.upsert(keyMap.values(), Customer_Order_Inventory__c.Fields.key__c, false);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerOrderInventoryBatch', '1', this.entity + '-' + this.orderDate, String.valueOf(Datetime.now()));
        CustomerOrderInventoryDailyBatch ss  = new CustomerOrderInventoryDailyBatch(this.entity, String.valueOf(this.orderDate));
		Database.executeBatch(ss);
    }
}