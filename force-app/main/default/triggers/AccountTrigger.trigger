trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // new AccountTriggerHandler().run();
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new AccountTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new AccountTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new AccountTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new AccountTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new AccountTriggerHandler())
    // 验证客户流程提交条件
    // .bind(Triggers.Evt.beforeupdate, new AccountValidationTriggerHandler())
	.manage();
}