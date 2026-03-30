trigger TrainingTrigger on Training__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new TrainingTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new TrainingTriggerHandler())
    .manage();
}