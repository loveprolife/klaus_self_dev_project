/*
 * @Author: WFC
 * @Date: 2025-01-09 13:56:17
 * @LastEditors: WFC
 * @LastEditTime: 2025-07-04 17:14:17
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\aura\DailyReport\DailyReportHelper.js
 */
({
	checkSalesRegion : function(component, salesRegionSelect) {
        component.set("v.loadingCompleted", true);
        
		var recordId = component.get("v.recordId");
        var action = component.get("c.isPhaseIIIUser");
        var phase = component.get("c.isPhaseIIIIUser");
        console.log('recordId' + recordId);
        phase.setParams({
            recordId : recordId,
            salesRegion : salesRegionSelect
        });
        phase.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('salesRegion' + response.getReturnValue());
                var salesRegion = response.getReturnValue();
                if (salesRegion) {
                    component.set("v.isHisense", "yes");
                } else {
                    component.set("v.isHisense", "no");
                }
            } else {
                component.set("v.isHisense", "no");
            }

            if(component.get('v.isHisense') == "no"){
                action.setParams({
                    recordId : recordId,
                    salesRegion : salesRegionSelect
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('salesRegion' + response.getReturnValue());
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
            }
        });
        $A.enqueueAction(phase);
	}
})