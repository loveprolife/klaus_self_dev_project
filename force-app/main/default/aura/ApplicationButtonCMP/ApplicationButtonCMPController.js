({
    init : function(component, event, helper) {
        // var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set('v.url', window.location.href);
	},
    
    refreshview : function(component,event,helper) {
    	console.log("edit refreshview fire...");
        $A.get('e.force:refreshView').fire();
    },
 
    closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    onRender : function(cmp, event) {
        console.log("lwcWrapper onRender");
        if (cmp.get('v.url') && cmp.get('v.url') != window.location.href) {
            // window.location.reload();
            $A.get('e.force:refreshView').fire();
        }
    }
})