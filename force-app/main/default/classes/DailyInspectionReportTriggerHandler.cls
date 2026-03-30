/*
 * @Author: Su,Tiger Shanhu
 * @Date: 2023-06-28 11:28:49
 * @LastEditors: WFC
 * @LastEditTime: 2025-07-28 13:41:20
 * @Description: DailyInspectionReportTriggerHandler
 */
public with sharing class DailyInspectionReportTriggerHandler extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeInsert(){
        DailyInspectionReportTriggerHandHelper.upsertExternalId();
        System.debug('DailyInspectionReport insert----'+ JSON.serialize(this.newList));
        //DailyInspectionReportTriggerHandHelper.submitCheckAns((List<Daily_Inspection_Report__c>)this.newList,(List<Daily_Inspection_Report__c>)this.oldList);    
    }
    public override void beforeUpdate(){
        DailyInspectionReportTriggerHandHelper.upsertExternalId();
        DailyInspectionReportTriggerHandHelper.submitCheckAns((List<Daily_Inspection_Report__c>)this.newList,(List<Daily_Inspection_Report__c>)this.oldList);
    }
}