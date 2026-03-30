trigger WeeklySalesTarget on Weekly_Sales_Target__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new WeeklySalesTargetTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new WeeklySalesTargetTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new WeeklySalesTargetTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new WeeklySalesTargetTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new WeeklySalesTargetTriggerHandler())
    .bind(Triggers.Evt.afterdelete, new WeeklySalesTargetTriggerHandler())
	.manage();
}