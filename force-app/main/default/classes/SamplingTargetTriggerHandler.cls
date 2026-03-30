public with sharing class SamplingTargetTriggerHandler extends BaseTriggerHandler{

    public override void afterInsert(){
        SamplingTargetTriggerHandlerHelper.avoidRepeatSamplingConditionInsert(this.newList);
    }

    // public override void afterUpdate(){
    //     SamplingTargetTriggerHandlerHelper.avoidRepeatSamplingConditionInsert(this.newList);
    // }

}