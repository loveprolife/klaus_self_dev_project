public class MarketInsightTriggerHandler extends BaseTriggerHandler{
	public override void beforeUpdate(){
        NewPromoterDailyReportTriggerHelper.updateCustomerInfo(this.oldList, this.newList, 'Store__c');
    }
}