/*
 * @Author: WFC
 * @Date: 2025-02-19 09:32:01
 * @LastEditors: WFC
 * @LastEditTime: 2025-02-19 14:15:24
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\aura\ActualAchievementUploadCmp\ActualAchievementUploadCmpController.js
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
        var type = component.get("v.pageReference").state.c__type;
        component.set('v.objectLoad', 'Actual Achievement');
        component.set('v.type', type);
        console.log(window.name);
	},
})