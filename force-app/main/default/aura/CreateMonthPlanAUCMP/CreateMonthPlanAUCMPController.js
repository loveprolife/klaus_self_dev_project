/*
 * @Author: WFC
 * @Date: 2025-09-08 15:44:09
 * @LastEditors: WFC
 * @LastEditTime: 2025-09-08 15:44:45
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\aura\CreateMonthPlanAUCMP\CreateMonthPlanAUCMPController.js
 */
({
    refreshView : function(component,event,helper) {
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire()
    },
    createNewData : function(component,event,helper) {
    	var createAcountContactEvent = $A.get("e.force:createRecord");
		createAcountContactEvent.setParams({
		    "entityApiName": "Inspection_Shop_Task__c",
		    "defaultFieldValues": {
		        'Inspection_Plan__c' : component.get("v.recordId")
		    }
		});
		createAcountContactEvent.fire();
    },
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.isPhaseIIIUser");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var salesRegion = response.getReturnValue();
                if (salesRegion) {
                    component.set("v.isPhaseIII", "yes");
                } else {
                    component.set("v.isPhaseIII", "no");
                }
                // component.set("v.isPhaseIII", response.getReturnValue());
            }else{
                component.set("v.isPhaseIII", "no");
            }
        });
        $A.enqueueAction(action);
	}
})