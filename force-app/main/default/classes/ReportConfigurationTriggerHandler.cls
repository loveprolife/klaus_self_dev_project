public class ReportConfigurationTriggerHandler extends BaseTriggerHandler {
	public override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert(){
        ReportConfigurationTriggerHandlerHelper.assignValue(this.oldList, this.newList);
    }
    
    public override void afterInsert(){
        ReportConfigurationTriggerHandlerHelper.createItems(this.oldList, this.newList, false, Date.today().year());
    }

    public override void beforeUpdate(){
        ReportConfigurationTriggerHandlerHelper.assignValue(this.oldList, this.newList);
    }

    public override void afterUpdate(){
        ReportConfigurationTriggerHandlerHelper.modifyItems(this.oldList, this.newList);
    }
}