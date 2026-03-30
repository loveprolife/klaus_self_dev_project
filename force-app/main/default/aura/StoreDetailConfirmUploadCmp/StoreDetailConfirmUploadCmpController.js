/*
 * @Author: WFC
 * @Date: 2024-06-24 14:18:40
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-24 14:33:23
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\aura\StoreDetailConfirmUploadCmp\StoreDetailConfirmUploadCmpController.js
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
})