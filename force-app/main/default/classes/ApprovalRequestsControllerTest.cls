/*
 * @Author: WFC
 * @Date: 2024-03-01 11:06:41
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-06 10:39:16
 * @Description: 批量审批Controller Test类
 * @FilePath: \hisense005\force-app\main\default\classes\ApprovalRequestsControllerTest.cls
 */
@isTest
private class ApprovalRequestsControllerTest {
    
    static testmethod void test() {

        User u = [SELECT Id FROM User WHERE Name = 'System Admin' AND IsActive = true LIMIT 1];

        FOB__c f = new FOB__c();
        f.External_Key__c = 'aaaa';
        insert f;
        

        Approval.ProcessSubmitRequest req1 =   new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(f.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(u.Id);

        // req1.setNextApproverIds(new List<String>{u.Id});

        // Submit the record to specific process and skip the criteria evaluation
        // req1.setProcessDefinitionNameOrId('Customer_Onboard_HA_Legal_staff');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        System.runAs(u){
            ApprovalRequestsController.getApprovalData(New List<String>{});
            ApprovalRequestsController.getApprovalData(New List<String>{'ALLL'});
            List<ApprovalRequestsController.ApprovalData> aaList = new List<ApprovalRequestsController.ApprovalData>();
            ApprovalRequestsController.ApprovalData aa = new ApprovalRequestsController.ApprovalData();
            aa.id = newWorkItemIds.get(0);
            aaList.add(aa);
            ApprovalRequestsController.submitVerifyApprovalRequests('Approve', 'dd', u.id, JSON.serialize(aaList));
            ApprovalRequestsController.submitVerifyApprovalRequests('Reject', 'dd', u.id, JSON.serialize(aaList));
            ApprovalRequestsController.submitVerifyApprovalRequests('Reassign', 'dd', u.id, JSON.serialize(aaList));
            Savepoint sp = Database.setSavepoint();
            ApprovalRequestsController.submitApprovalRequests('Approve', 'dd', u.id, JSON.serialize(aaList));
            Database.rollback(sp);
            Savepoint sp1 = Database.setSavepoint();
            ApprovalRequestsController.submitApprovalRequests('Reject', 'dd', u.id, JSON.serialize(aaList));
            Database.rollback(sp1);
            ApprovalRequestsController.submitApprovalRequests('Reassign', 'dd', u.id, JSON.serialize(aaList));
        }
        
    }
 
}