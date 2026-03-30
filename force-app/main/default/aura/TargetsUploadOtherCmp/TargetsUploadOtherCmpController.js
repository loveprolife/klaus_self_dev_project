/*
 * @Author: WFC
 * @Date: 2025-02-18 11:32:01
 * @LastEditors: WFC
 * @LastEditTime: 2025-02-18 14:03:11
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\aura\TargetsUploadOtherCmp\TargetsUploadOtherCmpController.js
 */
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
        // var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set('v.objectLoad', 'Targets Other');
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})