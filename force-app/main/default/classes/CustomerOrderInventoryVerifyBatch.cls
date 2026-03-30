/*
 * @Author: WFC
 * @Date: 2023-10-07 15:54:39
 * @LastEditors: WFC
 * @LastEditTime: 2023-11-30 10:45:44
 * @Description: CustomerOrderInventoryVerifyBatch ss  = new CustomerOrderInventoryVerifyBatch('8510');
		Database.executeBatch(ss);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\CustomerOrderInventoryVerifyBatch.cls
 */
global class CustomerOrderInventoryVerifyBatch implements Database.Batchable<sObject> {
    public String query;
    public String entity;

    global CustomerOrderInventoryVerifyBatch(String entity) {
        this.entity = entity;
        this.query = 'SELECT Id, Quantity__c, Daily_Sales_Quantity__c ' + 
                     ' FROM Customer_Order_Inventory__c WHERE Entity__c = :entity ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Order_Inventory__c> coiList) {
        List<Customer_Order_Inventory_Daily__c> updateList = new List<Customer_Order_Inventory_Daily__c>();
        Integer i = 0;

        for (Customer_Order_Inventory__c coi : coiList) {
            Decimal allQuantity = coi.Quantity__c - coi.Daily_Sales_Quantity__c;
            // 按照日报日期，自动生成Name倒叙查询
            List<Customer_Order_Inventory_Daily__c> coidList = [SELECT id, Exceed__c, Quantity__c FROM Customer_Order_Inventory_Daily__c WHERE Customer_Order_Inventory__c = :coi.Id
                                                                ORDER BY Daily_Sales__r.ReportDate__c DESC, Daily_Sales__r.Name DESC];
            for(Customer_Order_Inventory_Daily__c coid : coidList){
                if(allQuantity >= 0 && coid.Exceed__c){
                    i++;
                    coid.Exceed__c = false;
                    updateList.add(coid);
                }else if(allQuantity < 0 && !coid.Exceed__c){
                    i++;
                    coid.Exceed__c = true;
                    updateList.add(coid);
                }
                allQuantity = allQuantity + coid.Quantity__c;
                
                if(i == 9999){
                    String jobID = System.enqueueJob(new CustomerOrderInventoryDailyJob(updateList));
                    system.Debug('======== jobID==='+jobID);
                    updateList.clear();
                    i = 0;
                }
            }
        }
        if(updateList != null && updateList.size() > 0){
            Database.update(updateList);
        }
       
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerOrderInventoryVerifyBatch', '1', this.entity, String.valueOf(Datetime.now()));
        CustomerOrderInventoryVerifyDisBatch ss  = new CustomerOrderInventoryVerifyDisBatch(this.entity);
        Database.executeBatch(ss, 5);
    }
       
}