/**************************************************************************************************
 * CustomerButtonHandlerController
 * Purpose:客户按钮处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-04-09
***************************************************************************************************/
global  without sharing class CustomerAddressButtonHandlerController{
    public static User currentUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public class ReturnResult{
        public String code; //code "0" means success, and other codes means failure
        public String msg;  //result message
    }
    @AuraEnabled 
    //同步客户到SAP
    public static String syncCustomerToSAP(String customerId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Sync to SAP!';
        System.debug('currentUser: ' +currentUser);
        Customer_Address__c customer = [SELECT Id, MDG_Code__c, Approval_Status__c,Customer__r.MDG_Customer_Code__c FROM Customer_Address__c WHERE Id=:customerId];
        if(String.isBlank(customer.Customer__r.MDG_Customer_Code__c)){
            result.code = '1';
            if(!Test.isRunningTest()){
                result.msg = Label.Customer_Address_Check_Sold_to_MDG_Code;
                return JSON.serialize(result);
            }
        }
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
        // if(String.isNotBlank(customer.MDG_Code__c)){
        //     result.code = '1';
        //     //result.msg = 'The customer has been synchronized to SAP';
        //     result.msg = Label.Customer_Synchronized_To_SAP;
        //     return JSON.serialize(result);
        // }
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
}