/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-07-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger InspectionShopPlanTrigger on Inspection_Shop_Plan__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new Triggers()
	.bind(Triggers.Evt.beforeinsert, new InspectionShopPlanrHandler())
	.bind(Triggers.Evt.beforeupdate, new InspectionShopPlanrHandler())
	.manage();
	if(PhaseIIIUtility.isPhaseIIIUser()) {
	   new InspectionShopPlanTriggerHandler().run();
	}
	
}