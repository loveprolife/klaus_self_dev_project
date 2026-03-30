/*
 * @Author: YYL
 * @LastEditors: YYL
 */
({
    myAction : function(component, event, helper) {

    },

    init : function(component, event, helper) {

        var recordId = component.get("v.recordId");

        var action = component.get("c.getSalesRegion");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('salesRegion:' + response.getReturnValue());
                var salesRegion = response.getReturnValue();
                // if(salesRegion == 'Hisense Thailand'){
                //     //泰国暂时不用分账号，和其他国家使用同一个促销员日报
                //     component.set("v.isThailand", "yes");
                // }else{
                    component.set("v.isThailand", "no");
                    var action = component.get("c.isPhaseIIIUser");
                    action.setParams({
                        recordId : recordId
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            console.log('phaseIIIUser' + response.getReturnValue());
                            var salesRegion = response.getReturnValue();
                            if (salesRegion) {
                                component.set("v.isHisenseIII", "yes");
                            } else {
                                component.set("v.isHisenseIII", "no");
                            }
                        } else {
                            component.set("v.isHisenseIII", "no");
                        }
                    });
                    $A.enqueueAction(action);
                //}
            } else {
                component.set("v.isThailand", "no");
                component.set("v.isHisenseIII", "no");
            }
        });
        $A.enqueueAction(action);
	}
})