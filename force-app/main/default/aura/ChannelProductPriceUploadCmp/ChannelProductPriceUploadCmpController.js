/*
 * @Author: WFC
 * @Date: 2025-03-17 15:25:12
 * @LastEditors: WFC
 * @LastEditTime: 2025-03-17 15:25:53
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\aura\ChannelProductPriceUploadCmp\ChannelProductPriceUploadCmpController.js
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
        component.set('v.objectLoad', 'Channel Product Price');
        console.log(window.name);
	},
})