public without sharing class NewResponsiblePersonTriggerHandler extends BaseTriggerHandler{
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeUpdate(){
        System.debug('beforeUpdate');
        NewResponsiblePersonTriggerHandlerHelper.JudgmentduplicationPromoter(oldList,newList);
    }
    public override void beforeinsert(){
        NewResponsiblePersonTriggerHandlerHelper.JudgmentduplicationPromoter(oldList,newList);
    }
    public override void afterUpdate(){
        NewResponsiblePersonTriggerHandlerHelper.autoChangeFutureInspectionShopTaskOwnerAfterUpdate(oldList,newList);
    }
}