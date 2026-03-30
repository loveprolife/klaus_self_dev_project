/**********************************************************************
* Name: ApplicationTrigger
* Object: Application__c
* Purpose: ApplicationTrigger
* Author: yong
* Create Date: 2023-06-12
*************************************************************************/
trigger ApplicationTrigger on Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Label.Trigger_Switch =='ON'){
        new ApplicationTriggerHandler().run();
   }
}