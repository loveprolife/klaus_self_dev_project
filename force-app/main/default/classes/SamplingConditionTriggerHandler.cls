public with sharing class SamplingConditionTriggerHandler extends BaseTriggerHandler{
    
    // public override void beforeInsert(){
    //     SamplingConditionTriggerHandlerHelper.checkKeySamplingConditionInsert(this.newList);
    // }
    public override void afterInsert(){
        SamplingConditionTriggerHandlerHelper.avoidRepeatSamplingConditionInsert(this.newList);
    }
    // public override void beforeUpdate(){
    //     SamplingConditionTriggerHandlerHelper.checkKeySamplingConditionInsert(this.newList);
    // }
    public override void afterUpdate(){
        SamplingConditionTriggerHandlerHelper.avoidRepeatSamplingConditionInsert(this.newList);
    }

}