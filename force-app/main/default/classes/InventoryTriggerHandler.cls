/*
 * @Author: Su,Tiger Shanhu
 * @Date: 2023-06-27 14:22:02
 * @LastEditors: YYL
 * @LastEditTime: 2024-08-16 13:58:46
 * @Description: Inventory Trigger
 */
public with sharing class InventoryTriggerHandler extends BaseTriggerHandler{
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeInsert(){
        System.debug('Inventory insert----'+ JSON.serialize(this.newList));
        Id productInventroy = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        Id storeStock = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
        Id GridStock = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
        for (Inventory__c inventory : (List<Inventory__c> )this.newList) {
            if (String.isEmpty(inventory.UniqueKey__c)) {
               if (inventory.RecordTypeId == productInventroy) {
                // inventory.UniqueKey__c = inventory.Customer__c + ''+inventory.Shop__c + inventory.Product__c + 'Channel';
                inventory.UniqueKey__c = inventory.Customer__c + ''+inventory.Shop__c + inventory.Product__c + inventory.Inspection_Product_Item__c +'Channel';
               }
               if (inventory.RecordTypeId == storeStock) {
                inventory.UniqueKey__c = inventory.Customer__c +'' + inventory.GiftGrid__c + inventory.Shop__c  + inventory.Product__c + 'Shop';
               }
              if (inventory.RecordTypeId == GridStock) {
                inventory.UniqueKey__c = inventory.GiftGrid__c +''+ inventory.Shop__c  + inventory.Product__c + 'Grid';
               }
            }
        }      
    }
}