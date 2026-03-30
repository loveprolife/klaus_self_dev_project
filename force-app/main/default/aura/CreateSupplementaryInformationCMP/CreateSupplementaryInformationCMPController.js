/*
 * @Author: Rain
 * @Date: 2022-04-24 15:42:01
 * @LastEditors: Rain
 * @LastEditTime: 2022-04-24 15:44:06
 * @Description: 
 */
({
    refreshview : function(component,event,helper) {
    	console.log('aura:refreshview...');
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
    	console.log('aura:closeModal...');
        $A.get("e.force:closeQuickAction").fire();
    }
})