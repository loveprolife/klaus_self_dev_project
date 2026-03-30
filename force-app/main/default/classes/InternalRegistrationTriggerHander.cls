public  class InternalRegistrationTriggerHander extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        InternalRegistrationTriggerHanderHelper.GenerateXHN(this.newList);
        InternalRegistrationTriggerHanderHelper.createCheck(this.newList);
    }
    public override void beforeUpdate(){
        InternalRegistrationTriggerHanderHelper.GenerateXHN(this.newList);
        InternalRegistrationTriggerHanderHelper.createCheck(this.newList);
        //生成 动态 英文名
        InternalRegistrationTriggerHanderHelper.GenerateName(this.newList, this.oldList);
        //校验证书数量
        InternalRegistrationTriggerHanderHelper.createNumCheck(this.newList, this.oldList);
    }
    public override void afterInsert(){
        InternalRegistrationTriggerHanderHelper.autoCreatedExhibitionArrangement(this.newList);
    }
    public override void afterUpdate() {
        InternalRegistrationTriggerHanderHelper.sendEmail(this.newList, this.oldList);
    }
}