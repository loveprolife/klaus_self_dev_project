/*
 * @Author: WFC
 * @Date: 2023-07-31 14:12:45
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-31 15:52:14
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\aura\TrainingTaskUserAuraComponent\TrainingTaskUserAuraComponentController.js
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