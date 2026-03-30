/**********************************************************************
* 名称: InventoryItemTriggerHandler
* 功能: 
* 出入库明细trigger
* Author: feng xianfa
* Create Date: 2023-06-09
*************************************************************************/
public without sharing class InventoryItemTriggerHandler extends BaseTriggerHandler  {
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeInsert(){
        InventoryItemTriggerHandlerHelper2.copyFieldsFromInventory((List<StockItem__c>)this.newList);  
        System.debug('StockItem insert updateCustomerInfo----'+ JSON.serialize(this.newList));
        InventoryItemTriggerHandlerHelper.updateCustomerInfo(this.newList); 
        
        System.debug('StockItem insert updateInventory----'+ JSON.serialize(this.newList));
        InventoryItemTriggerHandlerHelper.updateInventory((List<StockItem__c>)this.newList);
    }
    
    public override void beforeUpdate(){
        InventoryItemTriggerHandlerHelper.changeSubmitAfter((List<StockItem__c>)this.oldList, (List<StockItem__c>)this.newList);
    }
}