trigger SAPTrigger on SAP__c (before update, before delete) {
    new Triggers()
    .bind(Triggers.Evt.beforeupdate, new SAPTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new SAPTriggerHandler())
    .manage();
}