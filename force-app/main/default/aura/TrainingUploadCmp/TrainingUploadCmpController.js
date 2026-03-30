/*
 * @Author: WFC
 * @Date: 2024-04-02 16:35:37
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-18 11:51:40
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\TrainingUploadCmp\TrainingUploadCmpController.js
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
        component.set('v.objectLoad', 'Training');
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
        // 处理数据
        var action = component.get("c.isCanUpload");
        action.setParams({
        });
        action.setCallback(this, function(response) {
            component.set('v.isCanUpload', response.getReturnValue());
        });
        $A.enqueueAction(action);

	},
})