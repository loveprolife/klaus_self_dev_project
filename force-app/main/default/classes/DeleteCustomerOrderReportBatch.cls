/**************************************************************************************************
 * Name:DeleteCustomerOrderReportBatch
 * Purpose: 删除CustomerOrderReport
 * Author: 
***************************************************************************************************/
global class DeleteCustomerOrderReportBatch implements Database.Batchable<sObject> {
    public String query;

    global DeleteCustomerOrderReportBatch() {
        this.query = 'select id from Customer_Order_Report__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Order_Report__c> corList) {
        Database.delete(corList);
    }

    global void finish(Database.BatchableContext BC) {
        InitCustomerOrderReportBatch icor = new InitCustomerOrderReportBatch();
        Database.executeBatch(icor,200);
    }
}