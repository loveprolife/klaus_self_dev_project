public class ExhibitionShuttleBusTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert(){        
    }

    public override void beforeUpdate(){
    	ExhibitionBusTriggerHandlerHelper.isArrangedForbiddenUpdate(this.oldList, this.newList);
    }
    public override void afterUpdate(){
    	ExhibitionBusTriggerHandlerHelper.sendEmail(this.oldList, this.newList);
    }
}