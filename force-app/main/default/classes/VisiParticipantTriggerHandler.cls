/**************************************************************************************************
 * VisiParticipantTriggerHandler
 * Purpose:VisiParticipant Trigger处理逻辑
 * Author: Roy
 * Create Date: 2019-03-31
***************************************************************************************************/
public class VisiParticipantTriggerHandler extends TriggerHandler{
	public override void beforeInsert(){
		System.debug('Taaaaaarigger.New '+Trigger.New);
		List<Visit_Participant__c> triggerVar = (List<Visit_Participant__c>)Trigger.New;
		List<Visit_Participant__c> vpList = [Select id from Visit_Participant__c where Hisense_Participant__c =: triggerVar[0].Hisense_Participant__c and Customer_Visit__c =:  triggerVar[0].Customer_Visit__c];
		//防止重复添加已存在的参与者
		if(triggerVar[0].Hisense_Participant__c != null & !vpList.isEmpty()){
			Trigger.New[0].addError(Label.Do_Not_Add_Participant_that_Already_Exist);
		}
	}
	public override void afterInsert(){
    //if adding hisense participant to visit record, share the visit record automatically to the user
		System.debug('Trigger.New '+Trigger.New);
		List<Customer_Visit__Share> cvShareList = new List<Customer_Visit__Share>();
		//给添加的参与者赋权限
		for(Visit_Participant__c vp: (List<Visit_Participant__c>)Trigger.New){
			Customer_Visit__Share cvs = new Customer_Visit__Share();
			cvs.ParentId = vp.Customer_Visit__c;
			cvs.UserOrGroupId = vp.Hisense_Participant__c;
			cvs.AccessLevel = 'Edit';
			cvs.RowCause = 'Manual';
			if(vp.Hisense_Participant__c != null){
				cvShareList.add(cvs);
			}
		}
		System.debug('cvShareList... '+cvShareList);
		if(cvShareList != null & !cvShareList.isEmpty()){
			Database.insert(cvShareList);
		}
	}

	public override void beforeDelete(){
		System.debug('Trigger.oLD '+Trigger.oLD);
		String visitId;
		String userId;
		for(Visit_Participant__c vp: (List<Visit_Participant__c>)Trigger.Old){
			visitId = vp.Customer_Visit__c;
			userId = vp.Hisense_Participant__c;
		}
		System.debug('visitId:: '+visitId);
		System.debug('userId:: '+userId);
		List<Customer_Visit__Share> cvShareDelList = [Select id from Customer_Visit__Share where ParentId =: visitId and UserOrGroupId =: userId];
		//删除参与者权限的逻辑
		if(cvShareDelList != null){
			Database.delete(cvShareDelList);
		}
	}

	public override void beforeUpdate(){
		//给参与者加读写的权限
		String visitId;
		String userId;
		for(Visit_Participant__c vp: (List<Visit_Participant__c>)Trigger.Old){
			visitId = vp.Customer_Visit__c;
			userId = vp.Hisense_Participant__c;
		}

		System.debug('visitId1 : '+visitId);
		System.debug('userId1 : '+userId);

		List<Customer_Visit__Share> cvShareDelList = [Select id from Customer_Visit__Share where ParentId =: visitId and UserOrGroupId =: userId];
		if(cvShareDelList != null){
			Database.delete(cvShareDelList);
		}

		System.debug('cvShareDelList1 : '+cvShareDelList);

		List<Customer_Visit__Share> cvShareList = new List<Customer_Visit__Share>();
		//添加权限
		for(Visit_Participant__c vp: (List<Visit_Participant__c>)Trigger.New){
			Customer_Visit__Share cvs = new Customer_Visit__Share();
			cvs.ParentId = vp.Customer_Visit__c;
			cvs.UserOrGroupId = vp.Hisense_Participant__c;
			cvs.AccessLevel = 'Edit';
			cvs.RowCause = 'Manual';
			if(vp.Hisense_Participant__c != null){
				cvShareList.add(cvs);
			}
		}
		System.debug('cvShareList1... '+cvShareList);
		if(cvShareList != null & !cvShareList.isEmpty()){
			Database.insert(cvShareList);
		}
	}
}