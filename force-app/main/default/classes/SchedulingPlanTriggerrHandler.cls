public class SchedulingPlanTriggerrHandler extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert() {
        SchedulingPlanTriggerrHandlerHelper.externalId(this.newList);
    }

    public override void beforeUpdate() {
        SchedulingPlanTriggerrHandlerHelper.externalId(this.newList);
        
    }

}