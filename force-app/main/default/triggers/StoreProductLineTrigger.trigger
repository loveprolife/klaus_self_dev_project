trigger StoreProductLineTrigger on Store_Product_Line__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new StoreProductLineTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new StoreProductLineTriggerHandler())
    .manage();
}