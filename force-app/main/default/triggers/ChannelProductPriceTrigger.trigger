trigger ChannelProductPriceTrigger on Channel_Product_Price__c (before insert, before update) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new ChannelProductPriceTriggerHandler())
	.bind(Triggers.Evt.beforeupdate, new ChannelProductPriceTriggerHandler())
	.manage();
}