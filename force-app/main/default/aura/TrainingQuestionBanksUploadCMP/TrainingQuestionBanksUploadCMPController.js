/*
 * @Author: WFC
 * @Date: 2023-05-26 14:15:54
 * @LastEditors: WFC
 * @LastEditTime: 2023-07-27 11:04:11
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\aura\TrainingQuestionBanksUploadCMP\TrainingQuestionBanksUploadCMPController.js
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