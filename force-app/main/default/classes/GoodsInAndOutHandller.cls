public with sharing class GoodsInAndOutHandller extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void afterInsert(){
        System.debug('GoodsReceiving insert----'+ JSON.serialize(this.newList));
        GoodsInAndOutHandllerHelper.createProductInventoryRecord(null,(List<GoodsInOut__c>)this.newList);
        System.debug('GoodsReceiving insert--requestAutoSubmit--'+ JSON.serialize(this.newList));
        GoodsInAndOutHandllerHelper.requestAutoSubmit(this.newList);
    }
    public override void beforeUpdate(){
        //GoodsInAndOutHandllerHelper.requestAutoSubmit(this.newList);
        System.debug('GoodsReceiving update----'+ JSON.serialize(this.newList));
        GoodsInAndOutHandllerHelper.createProductInventoryRecord((List<GoodsInOut__c>)this.oldList,(List<GoodsInOut__c>)this.newList);

        // Added By Sunny [2023-6-28]
        // System.debug('GoodsReceiving beforeUpdate updateCustomerInfo----');
        //NewPromoterDailyReportTriggerHelper.updateCustomerInfo(this.oldList, this.newList, 'StroeCode__c');
    }
    
    public override void afterUpdate(){
        System.debug('GoodsReceiving UPDATE--requestAutoSubmit--'+ JSON.serialize(this.newList));
        GoodsInAndOutHandllerHelper.requestAutoSubmit(this.newList);
        GoodsInAndOutHandllerHelper.changeSubmitAfter((List<GoodsInOut__c>)this.oldList,(List<GoodsInOut__c>)this.newList);
    }
    
}