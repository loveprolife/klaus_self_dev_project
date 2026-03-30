public class CommissionConfigurationTriggerHandler extends BaseTriggerHandler{

    protected override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        if(!CommissionConfigurationTriggerHelper.validateOOO(newList)) {
            return;
        }
        CommissionConfigurationTriggerHelper.reviseValue(newList);
    }
    
    public override void beforeUpdate(){
        if(!CommissionConfigurationTriggerHelper.validateOOO(newList)) {
            return;
        }
        CommissionConfigurationTriggerHelper.reviseValue(newList);
    }
}