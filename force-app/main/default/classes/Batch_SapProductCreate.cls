/**********************************************************************
* Name: Batch_SapProductCreate
* Object: SAP_Product__c 
* Create Date: 2025-02-14
*************************************************************************/
global class Batch_SapProductCreate implements Database.Batchable<sObject> {
    public String query;
    

    global Batch_SapProductCreate() {
        this.query = 'SELECT Id,ZCUSMODEL__c,Is_New__c FROM SAP_Product__c where Is_New__c = true and External_key__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<SAP_Product__c> sapProductList) {
        String[] salesRegions = new String[] {'Hisense South Africa','Hisense Indonesia', 'Hisense Chile', 'Hisense Japan', 'Hisense Peru',
        'Hisense Colombia', 'Hisense Argentina', 'Hisense West Africa', 'Hisense Saudi', 'Hisense Canada',
        'Hisense USA', 'Hisense Mexico', 'Hisense Thailand', 'Hisense Vietnam', 'Hisense Malaysia', 'Hisense Philippines'};

        List<Product__c> upsertList = new List<Product__c>();
        for(SAP_Product__c sapProduct : sapProductList){
            for(String salesRegion : salesRegions){
                upsertList.add(new Product__c(
                    Name = sapProduct.ZCUSMODEL__c,
                    Sales_Region__c = salesRegion,
                    SAP_Product__c = sapProduct.Id,
                    External_key__c = sapProduct.ZCUSMODEL__c + salesRegion
                ));
            }
            sapProduct.Is_New__c = false;
        }

        Database.upsert(upsertList, Product__c.External_Key__c,false);
        Database.update(sapProductList);
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}