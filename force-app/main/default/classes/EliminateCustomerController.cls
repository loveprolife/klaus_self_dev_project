/*
 * @Author: WFC
 * @Date: 2022-07-06 11:12:54
 * @LastEditors: WFC
 * @LastEditTime: 2022-07-25 10:33:32
 * @Description: 
 * @FilePath: \Hitest\force-app\main\default\classes\EliminateCustomerController.cls
 */

public without sharing class EliminateCustomerController{
    
    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @AuraEnabled
    public static OutPut saveData(String comments, Id recordId, String approvalName){
        OutPut out = new OutPut();
        try {
            // 验证淘汰流程和重启流程
            Account acc = [SELECT Eliminate_Approval_Status__c FROM Account WHERE Id =:recordId LIMIT 1];
            // 淘汰审批没有完成 点击重启流程按钮
            if(acc.Eliminate_Approval_Status__c != 'Approved' && approvalName == 'RestoreCustomer'){
                out.isSucess = false;
                out.errorMsg = Label.No_applicable_approval_process;
                return out; 
            }else if(acc.Eliminate_Approval_Status__c == 'Approved' && approvalName == 'EliminateCustomer'){
                // 淘汰审批通过 点击淘汰按钮
                out.isSucess = false;
                out.errorMsg = Label.No_applicable_approval_process;
                return out; 
            }
            
            // 客户淘汰流程
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
            req1.setComments(comments); 
            req1.setObjectId(recordId); 
            // Submit on behalf of a specific submitter 
            req1.setSubmitterId(currentUser.id); 
            // Submit the record to specific process and skip the criteria evaluation 
            req1.setSkipEntryCriteria(false); // Submit the approval request for the account 
            Approval.ProcessResult result = Approval.process(req1); // Verify the result 
            System.assert(result.isSuccess());

            out.isSucess = true;

            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'EliminateCustomerController';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = 'approvalName:' + approvalName + '———comments:' + comments + '———recordId:' + recordId + '———currentUser:' + currentUser.id;
            insert ic;

        } catch (Exception e) {
            out.isSucess = false;
            out.errorMsg = Label.No_applicable_approval_process;
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'EliminateCustomerController';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = 'approvalName:' + approvalName + '———comments:' + comments + '———recordId:' + recordId + '———currentUser:' + currentUser.id;
            ic.ErrorMsg__c = e.getMessage() + '————' +  e.getLineNumber();
            insert ic;
        }
        return out; 

    }

    public class OutPut {

        @AuraEnabled
		public Boolean isSucess {get; set;}

		@AuraEnabled
		public String errorMsg {get; set;}

       
    } 
}