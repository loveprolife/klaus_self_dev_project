public class NewPromoterDailyReportTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeUpdate(){
        NewPromoterDailyReportTriggerHelper.updateCustomerInfo(this.oldList, this.newList, 'Shop__c');
    }

    public override void afterUpdate(){
        NewPromoterDailyReportTriggerHelper.afterSubmit(this.oldList, this.newList);
    }
}