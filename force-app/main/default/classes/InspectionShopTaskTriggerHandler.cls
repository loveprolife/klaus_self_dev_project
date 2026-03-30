/**********************************************************************
* Name: InspectionShopTaskTriggerHandler
* Object: Inspection_Shop_Task__c
* Purpose: InspectionShopTaskTriggerHandler
* Author: yong
* Create Date: 2023-07-17
*************************************************************************/
public with sharing class InspectionShopTaskTriggerHandler extends BaseTriggerHandler{
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeInsert(){
        System.debug('------InspectionShopTaskTriggerHandler.beforeInsert------------------');
        InspectionShopTaskTriggerHandlerHelper.insertLimits(oldList,newList);
        InspectionShopTaskTriggerHandlerHelper.autoChangeOwner(oldList,newList);
    }
    public override void afterInsert(){
        // InspectionShopTaskTriggerHandlerHelper.autoChangeOwner(oldList,newList);
    }
}