public  class ExhibitionRegionHandler extends BaseTriggerHandler {
   public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
    	ExhibitionRegionHandlerHelper.initUserInfo(this.newList);
    }
    public override void beforeUpdate(){
    	ExhibitionRegionHandlerHelper.initUserInfo(this.newList);

    }
   
}