trigger CustomerAddressTrigger on Customer_Address__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CustomerAddressTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CustomerAddressTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CustomerAddressTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CustomerAddressTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new CustomerAddressTriggerHandler())
	.manage();
}