trigger CreditShippingPlan on Credit_Shipping_Plan__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CreditShippingPlanTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new CreditShippingPlanTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CreditShippingPlanTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new CreditShippingPlanTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new CreditShippingPlanTriggerHandler())
    .bind(Triggers.Evt.afterdelete, new CreditShippingPlanTriggerHandler())
	.manage();
}