trigger StoreInspectionManageTrigger on Store_Inspection_Manage__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new StoreInspectionManageTriggerHandler())
    .manage();
}