/*
 * @Author: YYL
 * @Date: 2024-01-18 13:58:04
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2024-01-18 14:49:36
 * @FilePath: /SalesForceUat/force-app/main/default/aura/CustomerTargetsUploadCmp/CustomerTargetsUploadCmp.cmp
 * @Description: 导入Customer Target 数据
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
        component.set('v.objectLoad', 'Customer Targets');
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})