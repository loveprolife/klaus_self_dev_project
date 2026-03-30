/*
 * @Author: WFC
 * @Date: 2025-09-08 15:44:09
 * @LastEditors: WFC
 * @LastEditTime: 2025-09-18 16:23:29
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\aura\EventReceiptDownloadPDFCmp\EventReceiptDownloadPDFCmpController.js
 */
({
    refreshView : function(component,event,helper) {
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire()
    },
})