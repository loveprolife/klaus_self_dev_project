/*
 * @Author: WFC
 * @Date: 2025-01-09 13:56:17
 * @LastEditors: WFC
 * @LastEditTime: 2025-09-23 16:20:56
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\aura\CreateMonthPlanCMP\CreateMonthPlanCMPController.js
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
	},
    initUserSalesRegion : function(component, event, helper) {
        var action = component.get("c.getSalesRegion");
        action.setParams({
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var flag = false;
                var salesRegion = response.getReturnValue();
                var pageLabelList = $A.get("$Label.c.Inspection_Task_Country").split(',');
                for  (var i = 0; i < pageLabelList.length; i++) {
                    if (salesRegion && salesRegion.includes(pageLabelList[i])) {
                        flag = true;
                        break;
                    }
                }
                if(flag){
                    component.set("v.isPhaseIII", "yes");
                }else {
                    component.set("v.isPhaseIII", "no");
                }

            }else{
                component.set("v.isPhaseIII", "no");
            }
        });
        $A.enqueueAction(action);
	},

})