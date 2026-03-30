global class Php_StoreSoInventoryBatch implements Database.Batchable<sObject> {
    public String query;
    public String salesRegion;

    global Php_StoreSoInventoryBatch(String salesRegion) {
        this.salesRegion = salesRegion;
        this.query = 'SELECT Id,Name FROM Shop__c where Sales_Region__c =: salesRegion ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<shop__c> storeList) {
        for(Shop__c item : storeList){
            Philippines_StoreSelloutInventoryCtrl.initDetail(item.Id);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Php_StoreSoInventoryBatch end');
    }
}