/**************************************************************************************************
 * Name: ExhibitionSetCustomerOwner
 * Object: ExpoApplyInfo__c
 * Purpose: 将第一个点击系统通知进入参展客户详情页面的分配用户设置为该记录的所有人
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-29         Created        
 
***************************************************************************************************/
public without sharing class ExhibitionSetCustomerOwner {
   
   @AuraEnabled
   public static ResData setCustomerOwner(String recordId){
   		ResData resData = new ResData();
   		try {
   			ExpoApplyInfo__c updateItem = NULL;
   		    for (ExpoApplyInfo__c item: [SELECT Id,Is_Allocated__c,Owner_User1__c,Owner_User2__c,Owner_User3__c,Owner_User4__c,Owner_User5__c
   		    	FROM ExpoApplyInfo__c WHERE Is_Allocated__c=FALSE AND Id=:recordId]) {
   		    	updateItem = item;
   		    	String currentUserId = UserInfo.getUserId();
   		    	System.debug('currentUserId--->'+currentUserId);
   		    	if (currentUserId == item.Owner_User1__c) updateItem.OwnerId = item.Owner_User1__c;
   		    	else if (currentUserId == item.Owner_User2__c) updateItem.OwnerId = item.Owner_User2__c;
   		    	else if (currentUserId == item.Owner_User3__c) updateItem.OwnerId = item.Owner_User3__c;
   		    	else if (currentUserId == item.Owner_User4__c) updateItem.OwnerId = item.Owner_User4__c;
   		    	else if (currentUserId == item.Owner_User5__c) updateItem.OwnerId = item.Owner_User5__c;
   		    	else return resData;

               updateItem.Is_Allocated__c = TRUE;
               UPDATE updateItem;
               resData.isSuccess = TRUE;
               resData.msg = '已将您分配为此客户的负责人！';
   		    }

   		   
   		}
   		catch (Exception e) {
   		    System.debug('ExhibitionSetCustomerOwner ERROR'+e.getLineNumber()+e.getMessage());
   		    resData.msg = 'SF系统异常，请联系管理员： ExhibitionSetCustomerOwner：'+e.getLineNumber()+e.getMessage();
   		}

   		return resData;
   		
   }

   public class ResData{
    	@AuraEnabled 
		public Boolean isSuccess;
		@AuraEnabled 
		public String msg;
		

		public ResData(){
			isSuccess = FALSE;
			msg = '未匹配到区组负责人！';
			
		}
	}
}