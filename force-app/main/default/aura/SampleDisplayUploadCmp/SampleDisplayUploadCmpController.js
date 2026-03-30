/*
 * @Author: WFC
 * @Date: 2024-06-24 09:31:37
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-09 11:23:54
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\aura\SampleDisplayUploadCmp\SampleDisplayUploadCmpController.js
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
        component.set('v.objectLoad', 'Sample Display');
        console.log('wwwww=====' + window.location.pathname);
	},
})