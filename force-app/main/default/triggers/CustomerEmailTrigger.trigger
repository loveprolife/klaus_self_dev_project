trigger CustomerEmailTrigger on Customer_Email__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CustomerEmailTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CustomerEmailTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerEmailTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CustomerEmailTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new CustomerEmailTriggerHandler())
    .bind(Triggers.Evt.afterdelete, new CustomerEmailTriggerHandler())
	.manage();
}