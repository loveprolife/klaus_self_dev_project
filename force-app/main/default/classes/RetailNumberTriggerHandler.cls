public with sharing class RetailNumberTriggerHandler extends BaseTriggerHandler   {
    protected override String getClassName() {
        return super.getClassName();
    }
    

    // Added By Sunny [2023-6-28]
    public override void beforeInsert(){
        RetailNumberTriggerHandlerHelper.updateTotalPrice(this.newList);
        RetailNumberTriggerHandlerHelper2.dailySalesfieldUpdate(this.oldList, this.newList);
        RetailNumberTriggerHandlerHelper.dailySalesfieldUpdateForAnayticsDashboard(this.oldList, this.newList);
        // RetailNumberTriggerHandlerHelper.updateSalesGoalInfo(this.oldList, this.newList);
        RetailNumberTriggerHandlerHelper.updateSamplingFlag(this.oldList, this.newList);
    }
    
    public override void beforeUpdate(){
        RetailNumberTriggerHandlerHelper.updateTotalPrice(this.newList);
        RetailNumberTriggerHandlerHelper2.dailySalesfieldUpdate(this.oldList, this.newList);
        RetailNumberTriggerHandlerHelper.dailySalesfieldUpdateForAnayticsDashboard(this.oldList, this.newList);
        // RetailNumberTriggerHandlerHelper.updateSalesGoalInfo(this.oldList, this.newList);
        NewPromoterDailyReportTriggerHelper.updateCustomerInfo(this.oldList, this.newList, 'Shop__c');
        RetailNumberTriggerHandlerHelper.updateSamplingFlag(this.oldList, this.newList);
	RetailNumberTriggerHandlerHelper.bindDailySalesTarget(oldList, newList);
        RetailNumberTriggerHandlerHelper.calculateDailySalesTargetChange(oldList, newList);
        // change daily sales
        RetailNumberTriggerHandlerHelper.changeSubmitAfter(this.oldList, this.newList);

    }
    public override void afterDelete(){
        // RetailNumberTriggerHandlerHelper.updateSalesGoalInfoAfterDelete(this.oldList, this.newList);
        RetailNumberTriggerHandlerHelper.calculateDailySalesTargetChange(oldList, newList);
    }

    // public override void afterInsert(){
    //     RetailNumberTriggerHandlerHelper.changeSAWeeklySalesTarget(oldList, newList);
    // }
    // public override void afterUpdate(){
    //     RetailNumberTriggerHandlerHelper.changeSAWeeklySalesTarget(oldList, newList);
    // }

}