/**********************************************************************
* 名称: InspectionShopPlanrHandler
* 功能: 
* 巡店计划trigger
* Author: Gerry
* Create Date: 2021-12-14
*************************************************************************/
public without sharing class InspectionShopPlanrHandler implements Triggers.Handler {
	public void handle() {
		if (Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)) {
			System.debug('进入了');
			//赋值ownerId 供重复规则使用
			for (Inspection_Shop_Plan__c shopPlan : (List<Inspection_Shop_Plan__c>)Trigger.new) {
				shopPlan.OwnerId__c = shopPlan.OwnerId;		
			}	
		}
	}    
}