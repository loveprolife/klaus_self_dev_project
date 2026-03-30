/*
 * @Author: WFC
 * @Date: 2023-11-14 10:29:08
 * @LastEditors: WFC
 * @LastEditTime: 2023-11-14 10:29:34
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\InventoryUploadCmp\InventoryUploadCmpController.js
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
        component.set('v.objectLoad', 'Inventory');
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})