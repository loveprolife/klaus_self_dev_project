trigger CustomerSalesForecastTrigger on Customer_Sales_Forecast__c (before insert, before update, before delete, after insert, after update) {
    // new AccountTriggerHandler().run();
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new CustomerSalesForecastTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerSalesForecastTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CustomerSalesForecastTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CustomerSalesForecastTriggerHandler())
    .manage();
}