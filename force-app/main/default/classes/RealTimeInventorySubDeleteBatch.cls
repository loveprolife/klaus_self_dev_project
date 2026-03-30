/*
 * @Author: WFC
 * @Date: 2024-01-16 10:17:16
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-17 09:24:19
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventorySubDeleteBatch.cls
 */
global class RealTimeInventorySubDeleteBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventorySubDeleteBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Id ' + 
                     ' FROM Real_Time_Inventory_Sub__c ' +
                     ' WHERE Sales_Region__c = :salesRegion ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Real_Time_Inventory_Sub__c> rtisList) {
        Database.delete(rtisList);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventorySubDeleteBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventorySubInitializeBatch ss  = new RealTimeInventorySubInitializeBatch(this.salesRegion, String.valueOf(this.orderDate));
        Database.executeBatch(ss);
    }
}