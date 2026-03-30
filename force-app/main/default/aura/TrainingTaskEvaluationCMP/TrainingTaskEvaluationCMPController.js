/*
 * @Author: WFC
 * @Date: 2023-06-15 09:17:36
 * @LastEditors: WFC
 * @LastEditTime: 2023-06-15 17:20:59
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\aura\TrainingTaskEvaluationCMP\TrainingTaskEvaluationCMPController.js
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
})