/*
 * @Author: WFC
 * @Date: 2024-04-08 16:18:19
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-09 09:36:32
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\qrcodeCmp\qrcodeCmpController.js
 */
({
    // doInit : function(component, event, helper) {
	// 	component.set("v.pdfUrl", "/apex/qrcodePage?ID="+component.get("v.recordId"));//v 是组件属性集的值提供程序
	// },

	refreshView : function(component,event,helper) {
        console.log('click cancel...refreshView' );
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        console.log('click cancel...closeModal');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
})