({
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.isPhaseIIIUser");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('salesRegion' + response.getReturnValue());
                var salesRegion = response.getReturnValue();
                if (salesRegion) {
                    component.set("v.isHisenseIII", "yes");
                } else {
                    component.set("v.isHisenseIII", "no");
                }
            } else {
                component.set("v.isHisenseIII", "no");
            }
        });
        $A.enqueueAction(action);
	},

    refreshview : function(component,event,helper) {
    	console.log("edit refreshview fire...");
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})