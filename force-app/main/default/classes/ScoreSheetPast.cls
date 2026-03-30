/*
 * @Author: YW
 * @Date: 2023-05-24 15:11:35
 * @LastEditors: WFC
 * @LastEditTime: 2025-05-15 11:16:10
 * @Description: test if customer has score sheet score lower than 60
 * @FilePath: \HiTest20250422\force-app\main\default\classes\ScoreSheetPast.cls
 */

public with sharing class ScoreSheetPast {

    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @AuraEnabled
    public static Boolean passSixty(Id recordId) {
        //查询客户下打分表不够60分，审批进入前进行校验
        AggregateResult[] ssResults= [SELECT Customer__c,count(id) FROM Score_Sheet__c WHERE Customer__c =:recordId AND Evaluated_Score__c < 60 GROUP BY Customer__c ];
        Map<String,integer> ssMap = new Map<String,integer>();
        if(ssResults.size()>0){
            return true;
        }else {
            return false;
        }
    }

    @AuraEnabled
    public static OutPut saveData(String comments, Id recordId, String approvalName){
        OutPut out = new OutPut();
        try {
           
            // 客户审批流程
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
            ic.Class__c = 'ScoreSheetPast';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = 'approvalName:' + approvalName + '———comments:' + comments + '———recordId:' + recordId + '———currentUser:' + currentUser.id;
            insert ic;

        } catch (Exception e) {
            out.isSucess = false;
            // out.errorMsg = Label.No_applicable_approval_process;
            out.errorMsg = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(': ['));
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'ScoreSheetPast';
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