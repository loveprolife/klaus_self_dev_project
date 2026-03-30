/**********************************************************************
* Name: ShopCenterLocationBatch
* Object: shop__c
* Purpose: 
* 门店地址位置自动查询(批处理)
* Author: wfc
* Create Date: 2022-02-22
* ShopCenterLocationBatch scr = new ShopCenterLocationBatch();
  Database.executeBatch(scr,200);
*************************************************************************/
global class ShopCenterLocationBatch implements Database.Batchable<sObject> {
    public String query;

    global ShopCenterLocationBatch() {
        this.query = 'select id,city__c,Address1__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s from Shop__c ' +
        ' where (city__c != null or Address1__c != null) and (Shop_Center_Location__Latitude__s = null or Shop_Center_Location__Longitude__s  = null) ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Shop__c> shopList) {
        // Map<String, String> shopMap = new Map<String, String>();
       
        // for(Shop__c shop : shopList){
        //     String addressNew = (String.isNotBlank(shop.City__c)?shop.City__c:'') + (String.isNotBlank(shop.Address1__c)?shop.Address1__c:'');
        //     if(String.isNotBlank(addressNew)){
        //         shopMap.put(shop.id, addressNew);
                
        //     }
        // }

        // // 异步调用google map接口
        // System.enqueueJob(new AsyncGoogleMap(shopMap));
        Map<Integer, List<Shop__c>> shopJobList = ShopCreateExternalKeyHandler.splitMap(shopList, 100);

        if (!Test.isRunningTest()) {
            System.enqueueJob(new AsyncGoogleMap(shopJobList, 0));
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

    
}