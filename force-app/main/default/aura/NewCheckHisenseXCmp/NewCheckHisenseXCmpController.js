/*
 * @Author: YYL
 * @LastEditors: YYL
 */
({
    myAction : function(component, event, helper) {

    },
    init: function (component, event, helper) {
        console.log("Initializing component...");
        var recordId = component.get("v.recordId"); // 获取当前记录ID
        // 设置状态为编辑模式（如果有 recordId）
        if (recordId) {
            component.set("v.status", "edit");
        }
    }
})