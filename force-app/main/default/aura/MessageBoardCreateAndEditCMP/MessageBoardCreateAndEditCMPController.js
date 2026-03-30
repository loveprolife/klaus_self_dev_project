/*
 * @Author: Rain
 * @Date: 2022-04-20 21:50:59
 * @LastEditors: Rain
 * @LastEditTime: 2022-04-20 23:07:36
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