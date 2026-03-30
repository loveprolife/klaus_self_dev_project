/*
 * @Author: WFC
 * @Date: 2024-01-12 14:24:21
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-12 14:38:02
 * @Description: 
 * 执行方法 Database.executeBatch(new ApprovalRecordHistoryBatch(''));
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\ApprovalRecordHistoryBatch.cls
 */
global class ApprovalRecordHistoryBatch implements Database.Batchable<sObject> {
    public String query;

    global ApprovalRecordHistoryBatch (String query) {
        this.query = query;
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<SObject> orderList) {
        List<Approval_Record_History__c> addList = new List<Approval_Record_History__c>();
        for(SObject so : orderList){
            List<ProcessInstanceStep> stepList = [SELECT CreatedDate FROM ProcessInstanceStep
                                            WHERE ProcessInstance.TargetObjectId = :so.Id
                                            ORDER BY CreatedDate];
            
            if(stepList != null && stepList.size() > 0){
                Approval_Record_History__c arh = new Approval_Record_History__c();
                arh.TargetObjectId__c = so.Id;
                arh.Approval_Status__c = 'Submitted';
                arh.Approval_Time__c = stepList[0].CreatedDate;

                Approval_Record_History__c arh1 = new Approval_Record_History__c();
                arh1.TargetObjectId__c = so.Id;
                arh1.Approval_Status__c = 'Approved';
                arh1.Approval_Time__c = stepList[stepList.size() - 1].CreatedDate;

                addList.add(arh);
                addList.add(arh1);
            }
        }

        insert addList;
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}