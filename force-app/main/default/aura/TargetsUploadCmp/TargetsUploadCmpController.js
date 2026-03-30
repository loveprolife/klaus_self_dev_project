/*
 * @Author: WFC
 * @Date: 2023-11-16 13:46:53
 * @LastEditors: WFC
 * @LastEditTime: 2023-11-16 13:47:18
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\TargetsUploadCmp\TargetsUploadCmpController.js
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
        component.set('v.objectLoad', 'Targets');
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})