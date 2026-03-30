public class ShopRetailDetailTriggerHandler extends BaseTriggerHandler{
	//public override void afterUpdate(){
        //ShopRetailDetailTriggerHandlerHelper.updateCustomerInfo(this.oldList,this.newList);
    //}
    public override void beforeUpdate(){
        System.debug('GoodsReceiving beforeUpdate----'+ JSON.serialize(this.newList));
        NewPromoterDailyReportTriggerHelper.updateCustomerInfo(this.oldList, this.newList, 'Shop__c');
    }
}