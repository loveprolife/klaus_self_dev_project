public class SchedulingTaskTriggerrHandler extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert() {
        SchedulingTaskTriggerrHandlerHelper.linkedPlan(this.newList);
        SchedulingTaskTriggerrHandlerHelper.externalId(this.newList);
    }

    public override void beforeUpdate() {
        SchedulingTaskTriggerrHandlerHelper.linkedPlan(this.newList);
        SchedulingTaskTriggerrHandlerHelper.externalId(this.newList);
        SchedulingTaskTriggerrHandlerHelper.checkImport(this.oldList,this.newList);
        
    }

}