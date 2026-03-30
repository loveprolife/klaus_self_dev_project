trigger POTrigger on PO__c (after insert, after update, before delete) {
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new POTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new POTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new POTriggerHandler())
    .manage();
}