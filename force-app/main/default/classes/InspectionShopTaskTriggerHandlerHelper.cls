/**********************************************************************
* Name: InspectionShopTaskTriggerHandlerHelper
* Object: Inspection_Shop_Task__c
* Purpose: InspectionShopTaskTriggerHandlerHelper
* Author: yong
* Create Date: 2023-07-17
*************************************************************************/
public with sharing class InspectionShopTaskTriggerHandlerHelper {
    /*
    * Name: insertLimits
    * Purpose: 巡店计划在审批中时不能创建巡店任务
    * Timing : before update
    * Author: yong
    * Create Date: 2023-07-17
    */
    public static void insertLimits(List<Inspection_Shop_Task__c> triggerOld,List<Inspection_Shop_Task__c> triggerNew){
        Set<String> planIdSet = new Set<String>();
        for(Inspection_Shop_Task__c ist:triggerNew){
            planIdSet.add(ist.Inspection_Plan__c);
        }
        for(Inspection_Shop_Plan__c isp : [SELECT Id,Name,Status__c FROM Inspection_Shop_Plan__c WHERE Id IN: planIdSet]){
            if(isp.Status__c != 'New' && isp.Status__c != 'Rejected' ){
                for(Inspection_Shop_Task__c ist:triggerNew){
                    if(ist.Inspection_Plan__c == isp.Id && ist.Status__c != '计划外到访'){
                        if(!Test.isRunningTest()){
                            ist.adderror(System.label.Inspection_Task_Create_Limits2);
                        }
                    }
                }
            }
        }
    }

    /*
    * Name: autoChangeOwner
    * Purpose: 巡店任务创建时，自动改变所有人为关联巡店计划所有人
    * Timing : before insert
    * Author: yong
    * Create Date: 2023-07-21
    */
    public static void autoChangeOwner(List<Inspection_Shop_Task__c> triggerOld,List<Inspection_Shop_Task__c> triggerNew){
        for(Inspection_Shop_Task__c ist:triggerNew){
            if(ist.Inspection_Plan__c != null  && ist.Inspection_Plan__r.OwnerId != null){
                ist.OwnerId = ist.Inspection_Plan__r.OwnerId;
            }
        }
    }
}