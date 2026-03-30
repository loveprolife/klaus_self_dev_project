trigger StoreDetailTrigger on Store_Detail__c (before insert, after insert, before update, after update, before delete) {
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new StoreDetailTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new StoreDetailTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new StoreDetailTriggerHandler())
    .manage();
}