trigger SchedulingPlanTriggerr on SchedulingPlan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new SchedulingPlanTriggerrHandler().run();
}