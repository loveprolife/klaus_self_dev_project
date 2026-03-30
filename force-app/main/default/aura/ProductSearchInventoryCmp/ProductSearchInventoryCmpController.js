({
    init: function (component, event, helper) {
        var pageLabelList = $A.get("$Label.c.Search_Inventory_All_Page_Label").split('&');
        component.set('v.productColumns', [
            { label: pageLabelList[1], fieldName: 'Name', type: 'text'},
            { label: pageLabelList[2], fieldName: 'StorageLocation', type: 'text'},
            { label: pageLabelList[3], fieldName: 'StockinWhse', type: 'text'},
            { label: pageLabelList[5], fieldName: 'ActualSOQty', type: 'text'},
            { label: pageLabelList[6], fieldName: 'EDIVOQty', type: 'text'},
            { label: pageLabelList[7], fieldName: 'DNQty', type: 'text'},
            { label: pageLabelList[8], fieldName: 'AvailableQtyExEDIVO', type: 'text'},
            { label: pageLabelList[9], fieldName: 'AvailableQtyIncEDIVO', type: 'text'}
        ]);
        var action = component.get("c.initData");
        action.setCallback(this, function(data) {
            var list = JSON.parse(data.getReturnValue());
            component.set("v.pageLabelList",pageLabelList);
            component.set("v.hEntityRelationList",list.hEntityRelationList);
            if(list.hEntityRelationList.length > 0 ){
                component.set('v.filter_hisenseEntity',list.hEntityRelationList[0].Hisense_Entity_Code__c);
            }
            var slList = [];
            for(var i=0;i<list.storageLocationList.length;i++){
                var storageLocation = {}; 
                storageLocation.label = list.storageLocationList[i].Name;
                storageLocation.value = list.storageLocationList[i].Value__c;
                storageLocation.hisenseEnity = list.storageLocationList[i].belong_to_he__c;
                slList.push(storageLocation);
            }
            component.set('v.allStorageLocationList',slList);
            component.set('v.storageLocationList',slList);
            
        });
        $A.enqueueAction(action);  
    },
    refreshStorageLocation: function (component, event, helper) {
        var hEnitityCode = component.get("v.filter_hisenseEntity");
        var list = component.get("v.allStorageLocationList");

        var slList = [];
        for(var i=0;i<list.length;i++){
            if(list.belong_to_he__c != hEnitityCode){
                continue;
            }
            var storageLocation = {}; 
            storageLocation.label = list[i].Name;
            storageLocation.value = list[i].Value__c;
            slList.push(storageLocation);
        }
        component.set('v.storageLocationList',slList);
        component.set('v.filter_storageLocation','');

    },
    handleChange: function (component, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        component.set('v.filter_storageLocation',selectedOptionValue.toString());

    },
    searchInventory: function (component, event, helper) {
        var productName = component.get("v.filter_productName");
        var hEnitityCode = component.get("v.filter_hisenseEntity");
        var storageLocation = component.get("v.filter_storageLocation");
        console.log('productName: ' + productName);
        console.log('hEnitityCode: ' + hEnitityCode);
        console.log('storageLocation: ' + storageLocation);
        if(productName == null || productName == ''){
            // alert('Please input product name first');
            alert($A.get("$Label.c.Search_Inventory_Must_Input_Product_Name_Alert"));
            return ;
        }
        component.set('v.showSpinner', true);
        var action = component.get("c.getProductInventory");
        action.setParams({
            productName : productName,
            hEnitityCode : hEnitityCode,
            storageLocation : storageLocation
        });
        action.setCallback(this, function(data) {
            var list = JSON.parse(data.getReturnValue());
            component.set('v.showSpinner', false);
            console.log('list:' + data.getReturnValue());
            if (list.isSuccess == 'True') {
                var inventoryList = [];
                for(var i=0;i<list.ProductStock.length;i++){
                    var productStockLine = {};
                    productStockLine.Name = list.CustomerModel;
                    productStockLine.StorageLocation = list.ProductStock[i].StorageLocation;
                    productStockLine.StockinWhse = list.ProductStock[i].StockinWhse;
                    productStockLine.ActualSOQty = list.ProductStock[i].ActualSOQty;
                    productStockLine.EDIVOQty = list.ProductStock[i].EDIVOQty;
                    productStockLine.DNQty = list.ProductStock[i].DNQty;
                    productStockLine.AvailableQtyExEDIVO = list.ProductStock[i].AvailableQtyExEDIVO;
                    productStockLine.AvailableQtyIncEDIVO = list.ProductStock[i].AvailableQtyIncEDIVO;
                    inventoryList.push(productStockLine);
                }
                component.set('v.productData', inventoryList); 
            }else{
                component.set('v.productData', []);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": list.failReason
                });
                toastEvent.fire();
                return;
            }
        });
        $A.enqueueAction(action); 
        
    }
})