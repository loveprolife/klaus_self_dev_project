/**************************************************************************************************
 * CustomerButtonHandlerController
 * Purpose:客户按钮处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-04-09
***************************************************************************************************/
global  without sharing class CustomerButtonHandlerController{
    public static User currentUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public class ReturnResult{
        public String code; //code "0" means success, and other codes means failure
        public String msg;  //result message
    }

    @AuraEnabled 
    //同步的RecordId是什么类型
    public static String getRecordIdType(String recordId){
        Id cid= Id.valueOf(recordId);
        return cid.getSObjectType().getDescribe().getName();
    }

    @AuraEnabled 
    //同步客户到SAP
    public static String syncCustomerToSAP(String customerId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Sync to SAP!';
        System.debug('currentUser: ' +currentUser);
        // 同步类型为客户或者客户拓展
        Id cid= Id.valueOf(customerId);
        String recordObject = cid.getSObjectType().getDescribe().getName();
        if(recordObject == 'Account'){
            Account customer = [SELECT Id,Name,Customer_Status__c,Approval_Status__c,SAP_Customer_Code__c,MDG_Customer_Code__c FROM Account WHERE Id=:customerId];
            //lzx  2025-02-06崔杰要求注释
            // if(!currentUser.Profile.Name.contains('Sales Manager')
            // && !currentUser.Profile.Name.contains('Sales Director')
            // && !currentUser.Profile.Name.contains('System Administrator')){
            //     result.code = '1';
            //     //result.msg = 'You do not have permission to operate, please contact the administrator';
            //     result.msg = Label.Common_No_Permission;
            //     return JSON.serialize(result);
            // }
            // if(!customer.Approval_Status__c.equals('Approved')){
            //     result.code = '1';
            //     //result.msg = 'Only an Approved customer can synchronize to SAP';
            //     result.msg = Label.Customer_Sync_To_SAP_With_Error_Status;
            //     return JSON.serialize(result);
            // }
            //lzx  2025-02-05崔杰要求更改
            if(String.isBlank(customer.SAP_Customer_Code__c)){
                result.code = '1';
                //result.msg = 'SAP customer code cannot be empty';
                result.msg = Label.SAP_Code_Miss;
                return JSON.serialize(result);
            }
            if(String.isBlank(customer.MDG_Customer_Code__c)){
                result.code = '1';
                //result.msg = 'MDG customer code cannot be empty';
                result.msg = Label.MDG_Code_Miss;
                return JSON.serialize(result);
            }
        } else if (recordObject == 'Customer_Extend__c'){
            Customer_Extend__c customerExtend = [SELECT Id,Name,Approval_Status__c,Customer__r.SAP_Customer_Code__c,Customer__r.MDG_Customer_Code__c 
                                                    FROM Customer_Extend__c 
                                                    WHERE Id = :customerId];
            // if(!customerExtend.Approval_Status__c.equals('Approved')){
            //     result.code = '1';
            //     //result.msg = 'Only an Approved customer can synchronize to SAP';
            //     result.msg = Label.Customer_Sync_To_SAP_With_Error_Status;
            //     return JSON.serialize(result);
            // }
            //lzx  2025-02-05崔杰要求更改
            if(String.isBlank(customerExtend.Customer__r.SAP_Customer_Code__c)){
                result.code = '1';
                //result.msg = 'SAP customer code cannot be empty';
                result.msg = Label.SAP_Code_Miss;
                return JSON.serialize(result);
            }
            if(String.isBlank(customerExtend.Customer__r.MDG_Customer_Code__c)){
                result.code = '1';
                //result.msg = 'MDG customer code cannot be empty';
                result.msg = Label.MDG_Code_Miss;
                return JSON.serialize(result);
            }
        }
        
        // MDG客户主数据 20241114
        String responseMsg = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(customerId);
        // String responseMsg = SyncCustomerInfoToSAP.postCustomerInfomationToSAP(customerId);
        if(!responseMsg.equals('SUCCESS')){
            result.code = '1';
            result.msg = responseMsg;
            return JSON.serialize(result);
        }
        return JSON.serialize(result);
    }
    @AuraEnabled
    //从SAP获取客户信用额度
    public static String getCustomerCreditLimit(String customerId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Get Credit Limit!';
        Account customer = [SELECT Id,Name,Customer_Status__c,Approval_Status__c,SAP_Customer_Code__c FROM Account WHERE Id=:customerId];
        if(String.isBlank(customer.SAP_Customer_Code__c)){
            result.code = '1';
            //result.msg = 'Please synchronize customer to SAP before getting credit limit';
            result.msg = Label.Customer_Sync_To_SAP_Alert;
            return JSON.serialize(result);
        }
        String responseMsg = SAPGetCreditLimit.syncCreditLimitOverdueFromSAP(customer.SAP_Customer_Code__c);
        if(!responseMsg.equals('SUCCESS')){
            result.code = '1';
            result.msg = responseMsg;
            return JSON.serialize(result);
        }
        return JSON.serialize(result);
    }
}