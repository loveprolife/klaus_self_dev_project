trigger PlanningTaskTrigger on Planning_Task__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    new PlanningTaskTriggerHandler().run();
}