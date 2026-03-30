trigger SamplingConditionTrigger on Sampling_Condition__c (before insert, after insert, before update, after update) {
    new SamplingConditionTriggerHandler().run();
}