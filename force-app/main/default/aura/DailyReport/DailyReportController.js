/*
 * @Author: YYL
 * @LastEditors: WFC
 */
({
	myAction : function(component, event, helper) {
		
	},

    // init : function(component, event, helper) {
    //     var recordId = component.get("v.recordId");
    //     var action = component.get("c.isPhaseIIIUser");
    //     var phase = component.get("c.isPhaseIIIIUser");
    //     console.log('recordId' + recordId);
    //     phase.setParams({
    //         recordId : recordId
    //     });
    //     phase.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             console.log('salesRegion' + response.getReturnValue());
    //             var salesRegion = response.getReturnValue();
    //             if (salesRegion) {
    //                 component.set("v.isHisense", "yes");
    //             } else {
    //                 component.set("v.isHisense", "no");
    //             }
    //         } else {
    //             component.set("v.isHisense", "no");
    //         }

    //         if(component.get('v.isHisense') == "no"){
    //             action.setParams({
    //                 recordId : recordId
    //             });
    //             action.setCallback(this, function(response) {
    //                 var state = response.getState();
    //                 if (state === "SUCCESS") {
    //                     console.log('salesRegion' + response.getReturnValue());
    //                     var salesRegion = response.getReturnValue();
    //                     if (salesRegion) {
    //                         component.set("v.isHisenseIII", "yes");
    //                     } else {
    //                         component.set("v.isHisenseIII", "no");
    //                     }
    //                 } else {
    //                     component.set("v.isHisenseIII", "no");
    //                 }
    //             });
    //             $A.enqueueAction(action);
    //         }
    //     });
    //     $A.enqueueAction(phase);
	// },

    init : function(component, event, helper) {
        component.set("v.salesRegionList", $A.get("$Label.c.Sales_Region_Filter").split(','));
        var recordId = component.get("v.recordId");
        // 没有id则为新建
        if(recordId == null || recordId == '' || recordId == undefined){
            // 过滤某些条件需要选择sales region
            var action = component.get("c.getSalesRegion");
            action.setParams({ });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('wwww---salesRegion----' + response.getReturnValue());
                    let salesRegionList = $A.get("$Label.c.Sales_Region_Filter").split(',');
                    let flag = false;
                    salesRegionList.forEach(item => {
                        if(item == response.getReturnValue()){
                            flag = true;
                        }
                    });
                    if(!flag){
                        component.set("v.selectTypeView", true);
                    }else {
                        helper.checkSalesRegion(component, '');
                    }
                }
            });
            $A.enqueueAction(action);
        }else {
            helper.checkSalesRegion(component, '');
        }
    },

    closeModal : function(component, event, helper) {
        component.set("v.selectTypeView", false);
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Daily_Inspection_Report__c',
                actionName: 'list'
            },
        };
        component.set("v.pageReference", pageReference);
        navService.navigate(pageReference);
    },

    continue : function(component, event, helper) {
        // 验证是否选择salesRegion
        if(component.get("v.salesRegion") == null || component.get("v.salesRegion") == '' || component.get("v.salesRegion") == undefined){
            var resultsToast = $A.get("e.force:showToast");
                if(resultsToast) {
                   resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": $A.get("$Label.c.Select_Sales_Region_Message")
                   });
                   resultsToast.fire();
                }
        }else {
            component.set("v.selectTypeView", false);
            helper.checkSalesRegion(component, component.get("v.salesRegion"));
        }
    },

    // handleChange : function(component, event, helper) {
    //     var salesRegion = event.getParam("value");
    //     component.set("v.salesRegion", salesRegion);
    // },

    handleChange: function(component,event,helper){
        var selectCmp = component.find("InputSelectSalesRegion");
        component.set("v.salesRegion", selectCmp.get("v.value"));
	},

    // init : function(component, event, helper) {
    //     var recordId = component.get("v.recordId");
    //     var getDimension = component.get("c.getSalesRegionDimension");
    //     console.log('recordId' + recordId);

    //     // phase.setParams({
    //     //     recordId : recordId
    //     // });
    //     getDimension.setCallback(this, function(response) {
    //         var state = response.getState();
    //         console.log('state' + state);wu
    //         if (state === "SUCCESS") {
    //             console.log('dimension' + JSON.stringify(response.getReturnValue()));
    //         } else {
                
    //         }
    //     });

    //     $A.enqueueAction(getDimension);
    // }
})