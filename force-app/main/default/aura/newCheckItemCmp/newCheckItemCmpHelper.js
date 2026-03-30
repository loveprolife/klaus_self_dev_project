/*
 * @Author: YYL
 * @LastEditors: YYL
 */
({
    /**
     * 解析 URL 参数
     * @param {String} paramName 参数名称
     */
    getUrlParameter: function (paramName) {
        var urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(paramName);
    },

    /**
     * 根据 RecordTypeId 处理逻辑
     * @param {Component} component Lightning Component
     * @param {String} recordTypeId RecordTypeId
     */
    handleRecordType: function (component, recordTypeId) {
        console.log("Handling RecordTypeId: ", recordTypeId);

        var action = component.get("c.getCountry");
        action.setParams({ recordTypeId: recordTypeId });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var recordName = response.getReturnValue();
                console.log("Record Type Name: ", recordName);

                // 根据 RecordType 名称判断是否允许新建记录
                if (
                    recordName === "USA" ||
                    recordName === "Canada" ||
                    recordName === "Peru" ||
                    recordName === "International" ||
                    recordName === "Mexico" ||
                    recordName === "Argentina"||
                    recordName === "Chile"  ||
                    recordName === "Australia"
                ) {
                    component.set("v.isNew", "yes");
                } else {
                    component.set("v.isNew", "no");
                }
            } else {
                console.error("Failed to fetch Country Info. State: ", response.getState());
                component.set("v.isNew", "no");
            }

            // 根据是否新建记录执行导航
            this.navigateBasedOnRecord(component);
        });
        $A.enqueueAction(action);
    },

    /**
     * 根据当前状态导航
     * @param {Component} component Lightning Component
     */
    navigateBasedOnRecord: function (component) {
        var isNew = component.get("v.isNew");
        var recordId = component.get("v.recordId");
        var recordTypeId = component.get("v.recordTypeId");
        var navService = component.find("navService");
        var pageReference;

        console.log("Is New Record: ", isNew);
        console.log("Record Id: ", recordId);

        if (isNew === "no") {
            if (!recordId) {
                // 新建记录
                pageReference = {
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "CheckItem__c",
                        actionName: "new"
                    },
                    state: { nooverride: 1, recordTypeId: recordTypeId }
                };
            } else {
                // 编辑现有记录
                pageReference = {
                    type: "standard__objectPage",
                    attributes: {
                        recordId: recordId,
                        actionName: "edit",
                        objectApiName: "CheckItem__c"
                    },
                    state: { nooverride: 1 }
                };
            }
            component.set("v.pageReference", pageReference);
            navService.navigate(pageReference);
        }
    }
});