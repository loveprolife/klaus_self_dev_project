public class CheckResultTriggerHandler extends BaseTriggerHandler {
    
    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void afterInsert(){
        CheckResultTriggerHandlerHelper.createTickets(this.oldList, this.newList);
    }

    public override void afterUpdate(){
        CheckResultTriggerHandlerHelper.createTickets(this.oldList, this.newList);
        CheckResultTriggerHandlerHelper.createTrainingDetails(this.oldList,this.newList);
        CheckResultTriggerHandlerHelper.createUnplannedSamples(this.oldList,this.newList);
    }


    public override void afterDelete(){
        //删除关联的 Training_Detail信息
        CheckResultTriggerHandlerHelper.deleteTrainDetail();
        CheckResultTriggerHandlerHelper.deleteUnplannedSample(this.oldList,this.newList);
    }
}