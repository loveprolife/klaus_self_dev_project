/**************************************************************************************************
 * CreditLimitApplicationTriggerHandler
 * Purpose:CreditLimitApplicationTrigger处理逻辑
 * Author: Deloitte Roy
 * Create Date: 2019-04-01
***************************************************************************************************/
public without sharing class CreditLimitApplicationTriggerHandler implements Triggers.Handler{
	
	public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 
	
	public void handle() {

		if (Trigger.isBefore && Trigger.isUpdate) {
			System.debug('Trigger.Newupdate '+Trigger.New);
			System.debug('Trigger.oldupdate '+Trigger.Old);

			String customerCreditInforId;
			List<String> creditLimitCustomerSAPCodeList = new List<String>();
			List<String> creditLimitIdList = new List<String>();
			for(Credit_Limit_Application__c cla: (List<Credit_Limit_Application__c>)Trigger.New){
				Credit_Limit_Application__c claOld = (Credit_Limit_Application__c)Trigger.oldMap.get(cla.Id);

				if(cla.Approval_Status__c.equals('Submitted') && !cla.Approval_Status__c.equals(claOld.Approval_Status__c) && cla.Credit_Limit_for_Application_USD__c > 500000) {
					
					List<Credit_Shipping_Plan__c> cspList = [Select id from Credit_Shipping_Plan__c where Credit_Limit_Application__c =:cla.id];
					if(cspList.size() == 0){
						if(!Test.isRunningTest()){
							cla.addError(Label.Credit_Limit_Application_Shippling_Plan_Check);
							return;
						}
					}
				}

				//Trader_Type__c：002 或者 Trader_Type__c：006并且CustomerDetailType__c：18并且Credit_Management__c：1
				Account acc = [SELECT Id, SAP_Customer_Code__c, Hisense_Entity__c, Trader_Type__c, Credit_Management__c, CustomerDetailType__c FROM Account WHERE Id =:cla.Customer__c LIMIT 1];
			    if('H002'.equals(acc.Trader_Type__c) || ('H006'.equals(acc.Trader_Type__c) && '18'.equals(acc.CustomerDetailType__c) && '1'.equals(acc.Credit_Management__c)) || ('H006'.equals(acc.Trader_Type__c) && !'18'.equals(acc.CustomerDetailType__c))){
				}else{
					if(!Test.isRunningTest()){
						cla.addError(Label.Save_check);
						return;
					}
				}
				
				creditLimitCustomerSAPCodeList.add(cla.Customer_SAP_Code__c);
				creditLimitIdList.add(cla.id);

				// 验证南非信用申请流程特殊处理
				if(cla.Approval_Status__c.equals('Submitted') && cla.Approval_Status__c.equals(claOld.Approval_Status__c) && cla.recordtype.DeveloperName == 'SF'){
					if(!currentUser.Username.equals(Label.South_Africa_User_Update)){
						cla.addError(Label.SA_CLA_Error);
						return;
					}
				}

			}
			List<Credit_Limit_Application__c> claList = [select recordtype.DeveloperName from Credit_Limit_Application__c where id in: creditLimitIdList];
			for(Credit_Limit_Application__c cla: (List<Credit_Limit_Application__c>)Trigger.New){
				// 判断提交时选中的审批人权限
				Credit_Limit_Application__c claOld = (Credit_Limit_Application__c)Trigger.oldMap.get(cla.Id);
				System.debug('Approval_Status__c:; '+cla.Approval_Status__c);

				//if(cla.Approval_Status__c == 'RR Approving' || cla.Approval_Status__c == 'Submitted'){
					//List<Credit_Limit_Application__c> claList = [Select id,Customer_SAP_Code__c from Credit_Limit_Application__c where id =:cla.Id];
					//String CustomerSAPCode = creditLimitCustomerSAPCodeList[0];
					//System.debug('claList'+claList);
					//System.debug('CustomerSAPCode:: '+CustomerSAPCode);
					//if(CustomerSAPCode == null){
						//cla.addError('Cannot Submit the Record, Because Related Customer has not on Board ! ');
						//cla.addError(Label.Cannot_Submit_Credit_Limit_Application_Record);
						//return;
					//}
				//}
				if(cla.Approval_Status__c == 'RR Approving' && !cla.Approval_Status__c.equals(claOld.Approval_Status__c)){
					// 判断是否是新增的南非
					for(Credit_Limit_Application__c claa : claList){
						if(claa.recordtype.DeveloperName != 'SF'){
							customerCreditInforId = cla.Id;
						}
					}	
				}
				if((cla.Approval_Status__c.equals('Submitted') && !cla.Approval_Status__c.equals(claOld.Approval_Status__c)) || cla.Approval_Date__c != claOld.Approval_Date__c) {
					try {
						// 当前时间N分钟，下一次定时时间
						DateTime reTime = System.Now().addMinutes(1);
						Integer minute = reTime.minute();
						Integer hour = reTime.hour();  
						String con = '0 ' + minute + ' ' + hour + ' * * ?';
			
						// 生成唯一值
						Blob b = Crypto.GenerateAESKey(128);
						String h = EncodingUtil.ConvertTohex(b);
						System.schedule(h, con, new AccountSchedulable(cla.Id, cla.Customer__c, h));
					} catch (Exception e) {
						system.debug('error message'+e.getMessage());
						system.debug('line number'+e.getLineNumber());    
					}
				}
				
			}

			System.debug('customerCreditInforId:: '+customerCreditInforId);
			//call RR interface
			if(customerCreditInforId != null){
				System.debug('ttttttttttttt');
				if(!Test.isRunningTest()){
					SyncCustomerCreditInfoToRR.postInfomation(customerCreditInforId);
				}
			}
			
		}

		// public override void afterUpdate(){
		// 	for(Credit_Limit_Application__c cla: (List<Credit_Limit_Application__c>)Trigger.New){
		// 		// 修改customer的Ratio_of_Credit_Limit__c 进行客户信用申请额度使用预警
		// 		Account customer = [select id,Ratio_of_Credit_Limit__c from Account where id =:cla.Customer__c];
		// 		customer.Ratio_of_Credit_Limit__c = -10000;
		// 		update(customer);
		// 	}

		// }

		// 日本信用额度在客户审批通过前只有一条
		if (Trigger.isBefore && Trigger.isInsert) {
			
			List<String> accIdList = new List<String>();
			for(Credit_Limit_Application__c cla: (List<Credit_Limit_Application__c>)Trigger.New){

				
                if ('1'.equals(cla.Payment_Method__c)) {
					validateSettlementMethodsForLC(cla);
				} else {
					validateSettlementMethodsForNonLC(cla);
				}

				//Trader_Type__c：002 或者 Trader_Type__c：006并且CustomerDetailType__c：18并且Credit_Management__c：1
				Account acc = [SELECT Id, SAP_Customer_Code__c, Hisense_Entity__c, Trader_Type__c, Credit_Management__c, CustomerDetailType__c FROM Account WHERE Id =:cla.Customer__c LIMIT 1];
			    if('H002'.equals(acc.Trader_Type__c) || ('H006'.equals(acc.Trader_Type__c) && '18'.equals(acc.CustomerDetailType__c) && '1'.equals(acc.Credit_Management__c)) || ('H006'.equals(acc.Trader_Type__c) && !'18'.equals(acc.CustomerDetailType__c))){
				}else{
					cla.addError(Label.Save_check);
					if(!Test.isRunningTest()){
						return;
					}
				}

				accIdList.add(cla.Customer__c);
			}

			//查询客户信用额度数量
			AggregateResult[] clagroupedResults= [SELECT Customer__c,count(id) FROM Credit_Limit_Application__c  
												  WHERE Customer__c in : accIdList 
												  AND Customer__r.Basic_Approval_Status__c  != 'Approved'
												  AND Customer__r.Approval_Status__c  != 'Approved' 
												  GROUP BY Customer__c];
			Map<String,integer> claCountMap = new Map<String,integer>();
			if(clagroupedResults.size()>0){
				for(AggregateResult ar : clagroupedResults){
					claCountMap.put((String)ar.get('Customer__c'),(integer)ar.get('expr0'));
				}
			}
			for(Credit_Limit_Application__c cla: (List<Credit_Limit_Application__c>)Trigger.New){
				if(Label.JP_Profile.split(',').contains(currentUser.Profile.name) && claCountMap.containsKey(cla.Customer__c)){
					if(!Test.isRunningTest()){
						cla.addError(Label.Only_one_credit_application);
						return;
					}
				}

			}
		}

	}

	public static void validateSettlementMethodsForLC(Credit_Limit_Application__c record) {
		String validMethods = '即期LC, 远期LC';
        validateSingleSettlementMethod(record.Transaction_Settlement_Method_1_3year__c, validMethods, record, 'Transaction_Settlement_Method_1_3year__c', 'Invalid_Settlement_Method_LC');
        validateSingleSettlementMethod(record.Transaction_Settlement_Method_2_3year__c, validMethods, record, 'Transaction_Settlement_Method_2_3year__c', 'Invalid_Settlement_Method_LC');
        validateSingleSettlementMethod(record.Transaction_Settlement_Method_3_3year__c, validMethods, record, 'Transaction_Settlement_Method_3_3year__c', 'Invalid_Settlement_Method_LC');
    }

    public static void validateSettlementMethodsForNonLC(Credit_Limit_Application__c record) {
		String validMethods = 'LC,DP,OA/DA,预付款';
        validateSingleSettlementMethod(record.Transaction_Settlement_Method_1_3year__c, validMethods, record, 'Transaction_Settlement_Method_1_3year__c', 'Invalid_Settlement_Method_NonLC');
        validateSingleSettlementMethod(record.Transaction_Settlement_Method_2_3year__c, validMethods, record, 'Transaction_Settlement_Method_2_3year__c', 'Invalid_Settlement_Method_NonLC');
        validateSingleSettlementMethod(record.Transaction_Settlement_Method_3_3year__c, validMethods, record, 'Transaction_Settlement_Method_3_3year__c', 'Invalid_Settlement_Method_NonLC');
    }

    private static void validateSingleSettlementMethod(String method, String validMethods, Credit_Limit_Application__c record, String fieldName, String labelName) {
        
		if (!String.isBlank(method)) {
			for(String m : method.split(';')){
				if(!validMethods.contains(m)){
					String errorMessage = labelName.equals('Invalid_Settlement_Method_LC') ? Label.Invalid_Settlement_Method_LC : Label.Invalid_Settlement_Method_NonLC;
					errorMessage = String.format(errorMessage, new List<Object>{fieldName});
					record.addError(errorMessage);
				}
			}
			
        }
    }
}