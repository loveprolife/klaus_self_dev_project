trigger CustomerExtendTrigger on Customer_Extend__c (before insert, before update, before delete, after insert, after update) {
    // new AccountTriggerHandler().run();
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new CustomerExtendTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerExtendTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new CustomerExtendTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CustomerExtendTriggerHandler())
    .manage();
}