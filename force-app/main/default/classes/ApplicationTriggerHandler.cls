/**********************************************************************
* Name: ApplicationTriggerHandler
* Object: Application__c
* Purpose: ApplicationTriggerHandler
* Author: yong
* Create Date: 2023-06-12
*************************************************************************/
public with sharing class ApplicationTriggerHandler extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }
    public override void beforeInsert(){
        System.debug('beforeInsert');
        ApplicationTriggerHandlerHelper.applicationAssignApprover(oldList,newList);
        ApplicationTriggerHandlerHelper.applicationLimits(oldList,newList);
    }
    public override void afterInsert(){
        System.debug('afterInsert');
        ApplicationTriggerHandlerHelper.applicationAutoSubmit(oldList,newList);
    }
    public override void beforeUpdate(){
        System.debug('beforeUpdate');
        // ApplicationTriggerHandlerHelper.autoAddCommentsAfterReject(oldList,newList);
    }
    public override void afterUpdate(){
        System.debug('afterUpdate');
        ApplicationTriggerHandlerHelper.applicationApproved(oldList,newList);
        ApplicationTriggerHandlerHelper.applicationApproverStatusChangeNotification(oldList,newList);
    }
}