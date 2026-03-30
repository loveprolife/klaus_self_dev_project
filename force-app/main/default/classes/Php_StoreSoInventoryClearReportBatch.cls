global class Php_StoreSoInventoryClearReportBatch implements Database.Batchable<sObject>{

    public String query;
    global Php_StoreSoInventoryClearReportBatch() {
        this.query = 'SELECT Id,Name FROM Inventory_Sales_Report__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Inventory_Sales_Report__c> inventorySalesReport) {
        Database.delete(inventorySalesReport);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Php_StoreSoInventoryClearReportBatch end');
    }
}