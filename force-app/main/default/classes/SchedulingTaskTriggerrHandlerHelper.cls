public without sharing class SchedulingTaskTriggerrHandlerHelper {
    
    public static void calculateRelatedValues(List<SchedulingTask__c> newList) {
        Map<Id, Application__c> appMap = new Map<Id, Application__c>([SELECT ID, LeaveType__c FROM Application__c WHERE ID IN :(new LisqContainer(newList).SelectSField('Application__c'))]);
        for (SchedulingTask__c task : newList) {
            if (appMap.containsKey(task.Application__c)) {
                task.ApplicationLeaveType__c = appMap.get(task.Application__c).LeaveType__c;
            }
            task.IsNormal__c = task.IsNormalF__c;
        }	
    }

    public static void externalId(List<SchedulingTask__c> newList) {
        for (SchedulingTask__c task : newList) {
            task.ExternalId__c = task.Store__c + '_' + task.User__c + '_' + String.valueOf(task.Scheduling_Date__c)+'_'+task.Responsible_person__c;
        }	
    }

    public static void linkedPlan(List<SchedulingTask__c> newList) {
        Map<String, SchedulingPlan__c> planMap = new Map<String, SchedulingPlan__c>();
        for (SchedulingTask__c task : newList) {
            SchedulingPlan__c plan = new SchedulingPlan__c();
            plan.Year__c = task.Scheduling_Date__c.year();
            plan.Month__c = task.Scheduling_Date__c.month();
            plan.OwnerId = task.User__c;
            plan.Responsible_person__c = task.Responsible_person__c;
            plan.ExternalId__c = String.valueOf(plan.Year__c) + '_' + String.valueOf(plan.Month__c)+'_'+plan.OwnerId+'_'+plan.Responsible_person__c;
            if (!planMap.containsKey(plan.ExternalId__c)) {
                planMap.put(plan.ExternalId__c, plan);
            }
        }
        upsert planMap.values() ExternalId__c;
        System.debug('planMap--->'+JSON.serialize(planMap));
        for (SchedulingTask__c task : newList) {
            String exid = task.Scheduling_Date__c.year()+'_'+task.Scheduling_Date__c.month()+'_'+task.User__c+'_'+task.Responsible_person__c;
            System.debug('exid--->'+exid);
            String planId = planMap.get(exid).Id;
            if (task.SchedulingPlan__c!=planId) {
                task.SchedulingPlan__c = planMap.get(exid).Id;
            }
        }
    }
    
    public static void checkImport(List<SchedulingTask__c> oldList,List<SchedulingTask__c> newList) {
        Map<String, SchedulingTask__c> oldMap = new Map<String, SchedulingTask__c>();
        for (SchedulingTask__c task : oldList) {
            oldMap.put(task.Id,task);
        }
        for (SchedulingTask__c task : newList) {
            if (task.IsImport__c && oldMap.get(task.Id).Status__c!=task.Status__c) {
                task.Status__c=oldMap.get(task.Id).Status__c;
            }
        }

    }
}