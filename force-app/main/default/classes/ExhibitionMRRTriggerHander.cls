public  class ExhibitionMRRTriggerHander extends BaseTriggerHandler {
   public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
    	ExhibitionMRRTriggerHanderHelper.validateRepetitionTime(this.newList);
    }
    public override void beforeUpdate(){
    	ExhibitionMRRTriggerHanderHelper.validateRepetitionTime(this.newList);
    }
}