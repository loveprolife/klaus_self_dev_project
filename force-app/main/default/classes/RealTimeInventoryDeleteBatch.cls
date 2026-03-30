/*
 * @Author: WFC
 * @Date: 2024-01-15 09:17:15
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-17 09:23:23
 * @Description: Database.executeBatch(new RealTimeInventoryDeleteBatch('Hisense South Africa', '2023-01-01'));
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventoryDeleteBatch.cls
 */
global class RealTimeInventoryDeleteBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventoryDeleteBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Id ' + 
                     ' FROM Real_Time_Inventory__c ' +
                     ' WHERE Sales_Region__c = :salesRegion ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Real_Time_Inventory__c> rtiList) {
        Database.delete(rtiList);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventoryDeleteBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventorySubDeleteBatch ss  = new RealTimeInventorySubDeleteBatch(this.salesRegion, String.valueOf(this.orderDate));
        Database.executeBatch(ss);
    }
}