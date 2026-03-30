trigger CustomerBanksTrigger on Customer_Banks__c (before insert, before update, before delete, after insert, after update) {
    // new AccountTriggerHandler().run();
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new CustomerBanksTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerBanksTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CustomerBanksTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CustomerBanksTriggerHandler())
    .manage();
}