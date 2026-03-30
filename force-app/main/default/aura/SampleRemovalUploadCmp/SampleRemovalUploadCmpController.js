/*
 * @Author: WFC
 * @Date: 2024-07-02 16:28:20
 * @LastEditors: WFC
 * @LastEditTime: 2024-07-02 16:28:42
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\aura\SampleRemovalUploadCmp\SampleRemovalUploadCmpController.js
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
        component.set('v.objectLoad', 'Sample Removal');
        console.log('wwwww=====' + window.location.pathname);
	},
})