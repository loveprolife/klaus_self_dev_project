/*
 * @Author: tom
 * @Date: 2024-11-22 13:55:06
 * @LastEditors: Do not edit
 * @LastEditTime: 2024-12-16 11:16:22
 */
({
	initCMP: function(component,event,helper){
        component.set('v.productLineColumns', [
            { label: $A.get("$Label.c.Product_Line"), fieldName: 'productLine', type: 'text'},
            { label: $A.get("$Label.c.Sales_Quantity"), fieldName: 'quantity', type: 'text'},
            { label: $A.get("$Label.c.Total_Stock"), fieldName: 'tStock', type: 'text'},
            { label: $A.get("$Label.c.Available_Stock"), fieldName: 'aStock', type: 'text'}
            
            // { label: $A.get("$Label.c.Stock_In_Transit"), fieldName: 'transit', type: 'text'}
        ]);
        
        var accId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        action.setParams({accId : accId});
        action.setCallback(this, function(data) {
            console.log('data' + data.getReturnValue());
            jsonData = JSON.parse(data.getReturnValue());
            console.log('jsonData' + jsonData);
            var productLineData = [];
            for(var i=0;i<jsonData.dataList.length;i++){
                var productLine = {};
                productLine.productLine = jsonData.dataList[i].productLine;
                productLine.quantity = jsonData.dataList[i].quantity;
                productLine.tStock = jsonData.dataList[i].tStock;
                productLine.aStock = jsonData.dataList[i].aStock;
                // productLine.transit = jsonData.dataList[i].transit;
                productLineData.push(productLine);
            }
            // if(jsonData.dataList.length > 0) {
            //     var reportId = jsonData.dataList[0].chatId;
            //     console.log(reportId);
            //     component.set("v.isShow",true);
            //     // component.set("v.chatId",reportId);
            // } else {
            //     component.set("v.chatId",'');
            //     component.set("v.isShow",false);
            // }
            // var reportId = jsonData.dataList[0].chatId;
            // console.log(reportId);
            // component.set("v.chatId",reportId);
            var reportId = $A.get("$Label.c.Php_Reports_Id");
            console.log('WWW'+$A.get("$Label.c.Php_Reports_Id"));
            if(reportId != null && jsonData.dataList.length > 0) {
                component.set("v.isShow",true);
            } else {
                component.set("v.isShow",false);
            }
            component.set("v.productLineListData",productLineData);
            component.set("v.isError",false);
        });
        $A.enqueueAction(action);
	},
    skipModal : function(component,event,helper) {
        var reportId = $A.get("$Label.c.Php_Reports_Id");
        console.log('WWW'+$A.get("$Label.c.Php_Reports_Id"));
        var accId = component.get("v.recordId");
        // var show = component.get("v.isShow");
        // var chatId = component.get("v.chatId");
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: reportId,
                objectApiName: 'Report',
                actionName: 'view'
            },
            state: {
                fv0: accId
            }
        };
        component.set("v.pageReference", pageReference);
        navService.navigate(pageReference);
        // console.log('click cancel...closeModal');
        // $A.get("e.force:closeQuickAction").fire();
        // $A.get('e.force:refreshView').fire();
    },
})