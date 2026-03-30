/*
 * @Author: WFC
 * @Date: 2024-12-16 16:22:40
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-16 16:23:05
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\aura\SampleDisplayPONewCmp\SampleDisplayPONewCmpController.js
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