trigger CustomerVisitTrigger on Customer_Visit__c(after insert,after update, before delete,before insert, before update) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CustomerVisitTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CustomerVisitTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerVisitTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CustomerVisitTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new CustomerVisitTriggerHandler())
	.manage();
}