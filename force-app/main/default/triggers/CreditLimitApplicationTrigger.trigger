trigger CreditLimitApplicationTrigger on Credit_Limit_Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // new CreditLimitApplicationTriggerHandler().run();
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CreditLimitApplicationTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CreditLimitApplicationTriggerHandler())
    // .bind(Triggers.Evt.afterupdate, new CreditLimitApplicationTriggerHandler())
    // .bind(Triggers.Evt.afterinsert, new CreditLimitApplicationTriggerHandler())
	.manage();
}