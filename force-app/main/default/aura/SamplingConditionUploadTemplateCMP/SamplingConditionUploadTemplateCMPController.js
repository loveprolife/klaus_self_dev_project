/*
 * @Author: YYL
 * @Date: 2024-02-03 11:03:55
 * @LastEditors: YYL
 * @LastEditTime: 2024-02-03 11:07:49
 * @FilePath: /SalesForceUat/force-app/main/default/aura/SamplingConditionUploadTemplate/SamplingConditionUploadTemplateController.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
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
        component.set('v.objectLoad', 'Sampling Condition Template');
        component.set('v.showDownload', true);
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})