public class ExhibitionVehicalTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert(){
    	// ExhibitionVehicalTriggerHandlerHelper.initInternalRegistration(this.newList);
        
    }

    public override void beforeUpdate(){
    	// ExhibitionVehicalTriggerHandlerHelper.initInternalRegistration(this.newList);

        //20240929 发呢配车辆后邮件推送关闭
    	ExhibitionVehicalTriggerHandlerHelper.isArrangedForbiddenUpdate(this.oldList, this.newList);
    }
    public override void afterUpdate(){
        //20240929 发呢配车辆后邮件推送关闭
    	ExhibitionVehicalTriggerHandlerHelper.sendEmail(this.oldList, this.newList);
    }
}