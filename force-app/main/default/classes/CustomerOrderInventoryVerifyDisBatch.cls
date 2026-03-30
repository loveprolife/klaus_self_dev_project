/*
 * @Author: WFC
 * @Date: 2023-10-07 15:54:39
 * @LastEditors: WFC
 * @LastEditTime: 2023-10-10 10:06:40
 * @Description: CustomerOrderInventoryVerifyDisBatch ss  = new CustomerOrderInventoryVerifyDisBatch('8510');
        Database.executeBatch(ss);
 * @FilePath: \HisenseAll0912\force-app\main\default\classes\CustomerOrderInventoryVerifyDisBatch.cls
 */
global class CustomerOrderInventoryVerifyDisBatch implements Database.Batchable<sObject> {
    public String query;
    public String entity;

    global CustomerOrderInventoryVerifyDisBatch (String entity) {
        this.entity = entity;
        this.query = 'SELECT Id, Quantity__c, Distributor_Inventory_Quantity__c ' + 
                     ' FROM Customer_Order_Inventory__c WHERE Entity__c = :entity';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Order_Inventory__c> coiList) {
        List<Customer_Order_Inventory_Distributor__c> updateList = new List<Customer_Order_Inventory_Distributor__c>();
        for (Customer_Order_Inventory__c coi : coiList) {
            Decimal allQuantity = coi.Quantity__c - coi.Distributor_Inventory_Quantity__c;
            // 按照日报日期倒叙查询
            List<Customer_Order_Inventory_Distributor__c> coidList = [SELECT id, Exceed__c, Quantity__c FROM Customer_Order_Inventory_Distributor__c 
                                                                        WHERE Customer_Order_Inventory__c = :coi.Id
                                                                        ORDER BY Distributor_Inventory__r.CreatedDate DESC, Distributor_Inventory__r.name DESC];
            for(Customer_Order_Inventory_Distributor__c coid : coidList){
                coid.Exceed__c = true;
                if(allQuantity >= 0){
                    coid.Exceed__c = false;
                }
                updateList.add(coid);

                allQuantity = allQuantity + coid.Quantity__c;
            }
        }
        Database.update(updateList);

    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerOrderInventoryVerifyDisBatch', '1', this.entity, String.valueOf(Datetime.now()));
    }
       
}