public class ExhibitionHotelTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert(){        
    }

    public override void beforeUpdate(){
    	ExhibitionHotelTriggerHandlerHelper.isArrangedForbiddenUpdate(this.oldList, this.newList);
        ExhibitionHotelTriggerHandlerHelper.dataSupplement(this.oldList,this.newList);
    }
    public override void afterUpdate(){
        //同步舍友数据
        ExhibitionHotelTriggerHandlerHelper.updateRoommateDate(this.oldList, this.newList);
    	ExhibitionHotelTriggerHandlerHelper.sendEmail(this.oldList, this.newList);
    }
}