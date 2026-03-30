/**********************************************************************
* Name: ShopExternalKeyBatch
* Object: shop__c
* Purpose: 
* 门店编码(批处理)
* Author: wfc
* Create Date: 2022-02-23
* ShopExternalKeyBatch scr = new ShopExternalKeyBatch();
  Database.executeBatch(scr,200);
*************************************************************************/
global class ShopExternalKeyBatch implements Database.Batchable<sObject> {
    public String query;

    global ShopExternalKeyBatch () {
        this.query = 'select id,Grid_All__c,Shop_External_Key__c from Shop__c where Grid_All__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Shop__c> shopList) {
        if(null != shopList && shopList.size() > 0){
            List<Shop__c> upList = new List<Shop__c>();
            for(Shop__c shop : shopList){
                if(!shop.Grid_All__c.equals(shop.Shop_External_Key__c)){
                    shop.Shop_External_Key__c = shop.Grid_All__c;
                    upList.add(shop);
                }
            }
            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ShopTriggerHandler');
            Database.update(upList);
            
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
            
        }
        
    }

    global void finish(Database.BatchableContext BC) {

    }

    
}