public with sharing class PromoterDailyReportHandler2 extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void afterInsert(){
        System.debug('PromoterDailyReport afterInsert--requestAutoSubmit--'+ JSON.serialize(this.newList));
        PromoterDailyReportHandler2Helper.requestAutoSubmit(this.newList);
        System.debug('PromoterDailyReport afterInsert----'+ JSON.serialize(this.newList));
        PromoterDailyReportHandler2Helper.createInventoryItem((List<Promoter_Daily_Report__c>)this.newList);   
    }
    public override void beforeUpdate(){
        NewPromoterDailyReportTriggerHelper.updateCustomerInfo(this.oldList, this.newList, 'Shop__c');

        
        List<Promoter_Daily_Report__c> changeList = new LisqContainer((List<Promoter_Daily_Report__c>)this.newList).WhereOne('Status__c','IsChanged',(List<Promoter_Daily_Report__c>)this.oldList).ToSobjectList();
        System.debug('PromoterDailyReport beforeUpdate----'+ JSON.serialize(this.newList));
        System.debug('PromoterDailyReport changeList----'+ JSON.serialize(changeList));
        //System.debug('PromoterDailyReport beforeUpdate----'+ JSON.serialize(this.newList));
        //PromoterDailyReportHandler2Helper.createInventoryItem((List<Promoter_Daily_Report__c>)this.newList);  
        System.debug('PromoterDailyReport beforeUpdate----'+ JSON.serialize(changeList));
        
        PromoterDailyReportHandler2Helper.createInventoryItem(changeList);
    }

    public override void afterUpdate(){
        NewPromoterDailyReportTriggerHelper.afterSubmit(this.oldList, this.newList);
        NewPromoterDailyReportTriggerHelper.afterApproved(this.oldList, this.newList);

        List<Promoter_Daily_Report__c> changeList = new LisqContainer((List<Promoter_Daily_Report__c>)this.newList).WhereOne('Status__c','IsChanged',(List<Promoter_Daily_Report__c>)this.oldList).ToSobjectList();
        System.debug('PromoterDailyReport afterUpdate--requestAutoSubmit--'+ JSON.serialize(this.newList));
        //PromoterDailyReportHandler2Helper.requestAutoSubmit(this.newList);
        PromoterDailyReportHandler2Helper.requestAutoSubmit(changeList);
    }
}