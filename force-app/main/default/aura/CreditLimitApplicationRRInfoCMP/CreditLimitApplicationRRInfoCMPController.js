/*
 * @Author: WFC
 * @Date: 2023-10-26 17:03:48
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-19 10:25:09
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\CreditLimitApplicationRRInfoCMP\CreditLimitApplicationRRInfoCMPController.js
 */
({
	myAction : function(component, event, helper) {

        const translate = {
            '限额申请' : 'Credit limit application',
            '审批中': 'Pending', 
            '同意': 'Approved', 
            '拒绝': 'Rejected', 
            '已审批': 'Completed', 
            '信保申请': 'Credit insurance application', 
            '尚未提交': 'Not Submitted',
            '已提交尚未批复': 'Submitted and pending',
            '已提交被驳回': 'Submitted but rejected',
            '已提交已批复': 'Submitted and approved',
            '限额复评': 'Credit limit re-evaluation'
        } 

		var recordId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        var rrAuditList = [];
        action.setParams({recordId : recordId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            for(var i=0;i<jsonData.rrAuditList.length;i++){
                var rrAuditItem = {};
                rrAuditItem.Id = jsonData.rrAuditList[i].Id;
                rrAuditItem.Audit_Node__c = translate[jsonData.rrAuditList[i].Audit_Node__c];
                rrAuditItem.Audit_Opinion__c = translate[jsonData.rrAuditList[i].Audit_Opinion__c];
                rrAuditItem.Audit_Person__c = jsonData.rrAuditList[i].Audit_Person__c;
                rrAuditItem.Audit_Status__c = translate[jsonData.rrAuditList[i].Audit_Status__c];
                rrAuditItem.Audit_Time__c = jsonData.rrAuditList[i].Audit_Time__c;
                rrAuditItem.Audti_Limit__c = jsonData.rrAuditList[i].Audti_Limit__c;
                rrAuditItem.Audti_Term__c = jsonData.rrAuditList[i].Audti_Term__c;
                rrAuditList.push(rrAuditItem);
            };
           
            component.set("v.rrAuditListData",rrAuditList);
        });
        $A.enqueueAction(action);
	},

    admit : function(component, event, helper) {
        component.set("v.loaded",true);

        const translate = {
            '限额申请' : 'Credit limit application',
            '审批中': 'Pending', 
            '同意': 'Approved', 
            '拒绝': 'Rejected', 
            '已审批': 'Completed', 
            '信保申请': 'Credit insurance application', 
            '尚未提交': 'Not Submitted',
            '已提交尚未批复': 'Submitted and pending',
            '已提交被驳回': 'Submitted but rejected',
            '已提交已批复': 'Submitted and approved',
            '限额复评': 'Credit limit re-evaluation'
        } 

        var recordId = component.get("v.recordId");
        var action = component.get("c.syncData");
        var jsonData;
        var rrAuditList = [];
        action.setParams({recordId : recordId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
                for(var i=0;i<jsonData.rrAuditList.length;i++){
                    var rrAuditItem = {};
                    rrAuditItem.Id = jsonData.rrAuditList[i].Id;
                    rrAuditItem.Audit_Node__c = translate[jsonData.rrAuditList[i].Audit_Node__c];
                    rrAuditItem.Audit_Opinion__c = translate[jsonData.rrAuditList[i].Audit_Opinion__c];
                    rrAuditItem.Audit_Person__c = jsonData.rrAuditList[i].Audit_Person__c;
                    rrAuditItem.Audit_Status__c = translate[jsonData.rrAuditList[i].Audit_Status__c];
                    rrAuditItem.Audit_Time__c = jsonData.rrAuditList[i].Audit_Time__c;
                    rrAuditItem.Audti_Limit__c = jsonData.rrAuditList[i].Audti_Limit__c;
                    rrAuditItem.Audti_Term__c = jsonData.rrAuditList[i].Audti_Term__c;
                    rrAuditList.push(rrAuditItem);
                };
            
                component.set("v.rrAuditListData",rrAuditList);
                component.set("v.loaded",false);
        });
        $A.enqueueAction(action);
	},
})