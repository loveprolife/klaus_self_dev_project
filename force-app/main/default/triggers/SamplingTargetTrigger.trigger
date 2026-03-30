trigger SamplingTargetTrigger on Sampling_Target__c (after insert, after update) {
    new SamplingTargetTriggerHandler().run();
}