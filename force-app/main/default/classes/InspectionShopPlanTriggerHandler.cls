/**********************************************************************
* Name: InspectionShopPlanTriggerHandler
* Object: Inspection_Shop_Plan__c
* Purpose: InspectionShopPlanTriggerHandler
* Author: yong
* Create Date: 2023-07-14
*************************************************************************/
public with sharing class InspectionShopPlanTriggerHandler extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeUpdate(){
        System.debug('beforeUpdate');
        InspectionShopPlanTriggerHandlerHelper.autoUpdateSubmitter(oldList,newList);
    }
    public override void afterUpdate(){
        System.debug('afterUpdate');
        InspectionShopPlanTriggerHandlerHelper.sendNotificationToSubmitter(oldList,newList);
    }
}