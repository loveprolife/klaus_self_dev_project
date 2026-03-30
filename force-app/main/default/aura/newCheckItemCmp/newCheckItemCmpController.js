({
    myAction: function (component, event, helper) {
        // 空方法备用
    },

    refreshView: function (component, event, helper) {
        console.log("Click cancel...refreshView");
        $A.get("e.force:refreshView").fire();
    },

    closeModal: function (component, event, helper) {
        console.log("Click cancel...closeModal");
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

    init: function (component, event, helper) {
        console.log("Initializing component...");
        var recordId = component.get("v.recordId"); // 获取当前记录ID
        console.log("wwww---recordId---" + recordId);
        // 设置状态为编辑模式（如果有 recordId）
        if (recordId) {
            component.set("v.status", "edit");
        }

        // recordId 是新建还是修改
        if(recordId){
            // 查询数据
            var action1 = component.get("c.getCheckItemById");
            action1.setParams({recordId : recordId});
            action1.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("wwww---- ", JSON.stringify(result));
                    component.set("v.recordTypeId", result.checkItem.RecordTypeId);
                    helper.handleRecordType(component, result.checkItem.RecordTypeId);
                } else {
                    console.error("查询checkItem报错. State: ", response.getState());
                }
            });
            $A.enqueueAction(action1);
            return;
        }

        // 获取 URL 参数并解析 RecordTypeId
        var recordTypeId = helper.getUrlParameter("recordTypeId");
        component.set("v.recordTypeId", recordTypeId);
        console.log("RecordTypeId from URL: ", recordTypeId);


        // 如果 URL 中包含 RecordTypeId，调用 RecordType 逻辑
        if (recordTypeId) {
            helper.handleRecordType(component, recordTypeId);
        } else {
            // 否则调用获取 SalesRegion 的逻辑
            var action = component.get("c.getSalesRegionInfo");
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("SalesRegion Info: ", result);

                    // 提取 RecordTypeId 并处理逻辑
                    var fetchedRecordTypeId = result.recordTypeId && result.recordTypeId.length > 0
                        ? result.recordTypeId[0].Id
                        : null;
                    component.set("v.recordTypeId", fetchedRecordTypeId);
                    if (fetchedRecordTypeId) {
                        helper.handleRecordType(component, fetchedRecordTypeId);
                    } else {
                        console.error("No RecordTypeId returned from SalesRegion Info.");
                    }
                } else {
                    console.error("Failed to fetch SalesRegion Info. State: ", response.getState());
                }
            });
            $A.enqueueAction(action);
        }
    }
})