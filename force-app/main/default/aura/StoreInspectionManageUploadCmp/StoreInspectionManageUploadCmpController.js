/*
 * @Author: WFC
 * @Date: 2023-09-20 09:23:10
 * @LastEditors: WFC
 * @LastEditTime: 2023-09-26 15:27:13
 * @Description: 
 * @FilePath: \HisenseAll0912\force-app\main\default\aura\StoreInspectionManageUploadCmp\StoreInspectionManageUploadCmpController.js
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
        component.set('v.objectLoad', 'Store Inspection Manage');
	},
})