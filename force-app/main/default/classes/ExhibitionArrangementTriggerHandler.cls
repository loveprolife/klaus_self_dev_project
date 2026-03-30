public class ExhibitionArrangementTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        ExhibitionArrangementTriggerHelper.relateExhibiton(this.newList);
    }
    public override void beforeUpdate(){
        ExhibitionArrangementTriggerHelper.relateExhibiton(this.newList);

    }
    public override void afterUpdate() {
    	ExhibitionArrangementTriggerHelper.sendEmail(this.newList, this.oldList);
    }
}