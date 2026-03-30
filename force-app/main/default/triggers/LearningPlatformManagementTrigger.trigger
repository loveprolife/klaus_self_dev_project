trigger LearningPlatformManagementTrigger on Learning_Platform_Management__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
    .bind(Triggers.Evt.beforedelete, new LearningPlatformManagementHandler())
    .bind(Triggers.Evt.afterinsert, new LearningPlatformManagementHandler())
    .manage();
}