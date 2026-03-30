/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-07-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger InspectionShopTaskTrigger on Inspection_Shop_Task__c (before insert,after insert,before update,after update,before delete,after delete) {
    new Triggers()

    //岗位共享IsChanges设置
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())

	.bind(Triggers.Evt.beforeinsert, new SetDateHandler())
	.bind(Triggers.Evt.beforeupdate, new SetDateHandler())
	.bind(Triggers.Evt.afterupdate, new SetDateHandler())
	.bind(Triggers.Evt.beforedelete, new SetDateHandler())
    .manage();
    if(PhaseIIIUtility.isPhaseIIIUser()) {
	   new InspectionShopTaskTriggerHandler().run();
    }
    
}