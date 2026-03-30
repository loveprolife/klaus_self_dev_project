/**************************************************************************************************
 * CreditLimitApplicationButtonController
 * Purpose:信用额度克隆按钮按钮
 * Author: Gerry
 * Create Date: 2019-5-20
***************************************************************************************************/
public without sharing class CreditLimitApplicationButtonController {

	public class Result{
		public String msg;
		public String code;
	}

	@AuraEnabled
	public static String cloneCreaditLimit(String creaditLimitId){
		System.debug('ID:'+creaditLimitId);
		Result re = new Result();
		re.code = '0';
		re.msg = Label.Credit_Limit_Application_Sucess;
		Credit_Limit_Application__c creditLimitClone = new Credit_Limit_Application__c();
		Savepoint sp = Database.setSavepoint();
		try {
			//进行对象所有字段的获取
			Map<String,Schema.SObjectField> reditLimitMap = Schema.SObjectType.Credit_Limit_Application__c.fields.getMap();
			String sql = 'SELECT '+Utility.getQueryStringByFieldMap(reditLimitMap)+' FROM Credit_Limit_Application__c WHERE Id=:creaditLimitId';
		    Credit_Limit_Application__c creditLimit = Database.query(sql);
		    //当Payment_Method__c为LC并且Approval_Status__c为Insurance Company Approved可以克隆
		    //或者当Payment_Method__c不为LC并且Approval_Status__c为Risk Management Committee Approved时可以克隆
		    // if (!(('1'.equals(creditLimit.Payment_Method__c)&&'Insurance Company Approved'.equals(creditLimit.Approval_Status__c))
		    // 	||(!'1'.equals(creditLimit.Payment_Method__c)&&'Risk Management Committee Approved'.equals(creditLimit.Approval_Status__c)))) {
		    // 	re.code = '1';
		    // 	re.msg = 'The record can not clone!';
		    // 	return JSON.serialize(re);
		    // }
		    creditLimitClone = creditLimit.clone(False);
		    creditLimitClone.Approval_Status__c = 'Draft';
		    // creditLimitClone.Credit_Limit_for_Application_USD__c = null;
		    // creditLimitClone.Credit_Application_Period_days__c = null;
		    creditLimitClone.Effective_Start_Time__c = null;
		    creditLimitClone.Effective_End_Time__c = null;
		    creditLimitClone.RR_Rejection_Time__c = null;
		    creditLimitClone.RR_Rejection_Person__c = null;
		    creditLimitClone.Credit_Rating__c = null;
		    creditLimitClone.RR_Approval_Information__c = null;
		    creditLimitClone.Recommended_Billing_Period_days__c = null;
		    creditLimitClone.Final_Availability__c = null;
		    Database.insert(creditLimitClone);
		}catch (Exception e) {
			System.debug('error:'+e.getMessage()+e.getLineNumber());
		    re.code = '1';
		    re.msg = Label.Credit_Limit_Application_Database_Error;
		    return JSON.serialize(re);
		}
		re.msg = creditLimitClone.Id;
		return JSON.serialize(re);
	}
    
}