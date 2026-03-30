/*
 * @Author: WFC
 * @Date: 2022-07-07 17:19:41
 * @LastEditors: WFC
 * @LastEditTime: 2022-07-07 17:20:31
 * @Description: 
 * @FilePath: \Hitest\force-app\main\default\aura\RestoreCustomer\RestoreCustomerController.js
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

    }
})