/*
 * @Author: WFC
 * @Date: 2023-09-08 17:40:27
 * @LastEditors: WFC
 * @LastEditTime: 2023-09-11 09:27:41
 * @Description: CustomerOrderInventoryClearBatch ss  = new CustomerOrderInventoryClearBatch('8110', '2023-01-01');
		Database.executeBatch(ss);
 * @FilePath: \HisenseAllThree\force-app\main\default\classes\CustomerOrderInventoryClearBatch.cls
 */
global class CustomerOrderInventoryClearBatch implements Database.Batchable<sObject> {
    public String query;
    public Date orderDate;
    public String entity;

    global CustomerOrderInventoryClearBatch(String entity, String orderDate) {
        this.entity = entity;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Id, Quantity__c, Is_Sync__c ' + 
                     ' FROM Customer_Order_Inventory__c ' +
                     ' WHERE Entity__c = :entity';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Order_Inventory__c> coiList) {
        for (Customer_Order_Inventory__c coi : coiList) {
            coi.Quantity__c = 0;
            coi.Is_Sync__c = false;
        }
        Database.update(coiList);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerOrderInventoryClearBatch', '1', this.entity + '-' + this.orderDate, String.valueOf(Datetime.now()));
        CustomerOrderInventoryBatch ss  = new CustomerOrderInventoryBatch(this.entity, String.valueOf(this.orderDate));
		Database.executeBatch(ss);
    }
       
}