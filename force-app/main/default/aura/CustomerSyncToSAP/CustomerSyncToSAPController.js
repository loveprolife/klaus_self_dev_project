/*
 * @Author: WFC
 * @Date: 2025-01-09 13:56:18
 * @LastEditors: WFC
 * @LastEditTime: 2025-02-10 11:34:13
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\aura\CustomerSyncToSAP\CustomerSyncToSAPController.js
 */
({
	myAction : function(component, event, helper) {
		var result = {};
		component.set('v.showSpinner', true);
		var action = component.get("c.getRecordIdType");
        var recordId = component.get("v.recordId");
        action.setParams({recordId : recordId});
		action.setCallback(this, function(data) {
			component.set('v.showSpinner', false);
		    if(data.getReturnValue() == 'Customer_Extend__c'){
				result.msg = $A.get("$Label.c.Customer_Extend_Sync_To_SAP_Confirm");
			}else {
				result.msg = $A.get("$Label.c.Customer_Sync_To_SAP_Confirm");
			}
			result.code = '1';
			component.set("v.result",result);                                                                                                                                                                                                                                                                                                                             
		});
		$A.enqueueAction(action); 
	},
	//确认同步客户到SAP
	selectSubmit:function(component,event,helper){
		component.set('v.showSpinner', true);
        var action = component.get("c.syncCustomerToSAP");
        var customerId = component.get("v.recordId");
        action.setParams({customerId : customerId});
		action.setCallback(this, function(data) {
		    var result = JSON.parse(data.getReturnValue());
		    console.log('result:'+ JSON.stringify(result));
		    component.set('v.showSpinner', false);
		    component.set("v.result",result); 
		    component.set("v.isSubmitted",true); 
		    if(result.code != null && result.code == '0'){
                $A.get("e.force:closeQuickAction").fire();
			    $A.get("e.force:refreshView").fire();
		    }	                                                                                                                                                                                                                                                                                                                                         
		});
		$A.enqueueAction(action);
	},
	assignCancel:function(component,event,helper){
		$A.get("e.force:closeQuickAction").fire();
	}
})