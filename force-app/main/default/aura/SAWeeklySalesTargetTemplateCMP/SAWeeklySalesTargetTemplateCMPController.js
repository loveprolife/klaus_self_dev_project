({
    refreshView : function(component,event,helper) {
        console.log('click cancel...refreshView' );
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        console.log('click cancel...closeModal');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    myAction : function(component, event, helper) {

    },
    init : function(component, event, helper) {
        component.set('v.objectLoad', 'SA Weekly Sales Target Template');
        component.set('v.showDownload', true);
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})