public class CommissionDetailTriggerHandler extends BaseTriggerHandler{

    protected override String getClassName() {
        return super.getClassName();
    }

    public override void afterInsert() {
        CommissionDetailTriggerHandlerHelper.createCommissionModules(newList);
    }
}