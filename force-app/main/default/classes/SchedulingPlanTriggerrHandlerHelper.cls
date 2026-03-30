public with sharing class SchedulingPlanTriggerrHandlerHelper {
    public static void externalId(List<SchedulingPlan__c> newList) {
        for (SchedulingPlan__c  plan : (List<SchedulingPlan__c  >)newList) {
            if (String.isNotBlank(plan.Responsible_person__c)) {
                plan.ExternalId__c = String.valueOf(plan.Year__c) + '_' + String.valueOf(plan.Month__c)+'_'+plan.OwnerId+'_'+plan.Responsible_person__c;
            }
        }	
    }
}