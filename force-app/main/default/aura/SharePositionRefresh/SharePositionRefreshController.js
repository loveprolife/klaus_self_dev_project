({
    init : function(component, event, helper) {

        var recordId = component.get("v.recordId");

        //检查是否已维护岗位权限
        var action = component.get("c.checkPosition");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.isError) {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showModal(component, event, '操作失败', result.msg, "error");
                }else {
                    component.set("v.showButton", true);
                }
            } else {
                $A.get("e.force:closeQuickAction").fire();
                helper.showModal(component, event, 操作失败, response.getErrors(), "error");
            }
        });

        $A.enqueueAction(action);
    },

    submit : function(component, event, helper) {

        var recordId = component.get("v.recordId");
        component.set("v.showButton", false);

        //检查客户开票信息是否完整
        var action = component.get("c.runRefreshJob");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (!result.isError) {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showModal(component, event, '操作成功', result.msg, "success");
                } else {
                    component.set("v.showButton", true);
                    helper.showModal(component, event, '操作失败', result.msg, "error");
                }
            } else {
                $A.get("e.force:closeQuickAction").fire();
                helper.showModal(component, event, 操作失败, response.getErrors(), "error");
            }
        });

        $A.enqueueAction(action);
    },

    closePopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    showSpinner : function(component, event, helper) {
        component.set("v.showWaiting", true);
    },

    hideSpinner : function(component, event, helper) {
        component.set("v.showWaiting", false);
    }
})