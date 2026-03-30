/**********************************************************************
* Name: InspectionShopPlanTriggerHandlerHelper
* Object: Inspection_Shop_Plan__c
* Purpose: InspectionShopPlanTriggerHandler
* Author: yong
* Create Date: 2023-07-14
*************************************************************************/
public with sharing class InspectionShopPlanTriggerHandlerHelper {
    /*
    * Name: autoUpdateSubmitter
    * Purpose: When inspection shop plan submit approval ,auto update submitter 提交审批时自动记录提交人
    * Timing : before update
    * Author: yong
    * Create Date: 2023-07-14
    */
    public static void autoUpdateSubmitter(List<Application__c> triggerOld,List<Application__c> triggerNew) {
        LisqContainer lc = new LisqContainer(triggerNew);
        List<Inspection_Shop_Plan__c> ispList = lc.Where1('Status__c', 'ISCHANGED', triggerOld).ToSobjectList();
        for(Inspection_Shop_Plan__c isp:ispList){
            if(isp.Status__c == 'Submitted'){
                isp.Submiter__c = UserInfo.getUserId();
            }
        }
    }
    /*
    * Name: sendNotificationToSubmitter
    * Purpose: after approved or rejected, send notification to submitter 审批通过\拒绝后通知提交人
    * Timing : after update
    * Author: yong
    * Create Date: 2023-07-14
    */
    public static void sendNotificationToSubmitter(List<Application__c> triggerOld,List<Application__c> triggerNew) {

        LisqContainer lc = new LisqContainer(triggerNew);
        List<Inspection_Shop_Plan__c> ispList = lc.Where1('Status__c', 'ISCHANGED', triggerOld).ToSobjectList();
        CustomNotificationType TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Custom_Notification'];

        for(Inspection_Shop_Plan__c isp:ispList){
            if(isp.Status__c == 'Approved' || isp.Status__c == 'Rejected'){
                String title = System.label.ApprovalNotificationTitle + ' ' + isp.Status__c;//Approval request for the application is
                String body = isp.Name;
                Set<String> receiveUserIdSet = new Set<String>();
                receiveUserIdSet.add(isp.Submiter__c);
                receiveUserIdSet.add(isp.CreatedById);
                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                currNotification.setTitle(title);
                currNotification.setBody(body);
                currNotification.setNotificationTypeId(TemplateInfoDetail.Id);
                currNotification.setTargetId(isp.Id);
                
                currNotification.send(receiveUserIdSet);
                
            }
        }
    }
}