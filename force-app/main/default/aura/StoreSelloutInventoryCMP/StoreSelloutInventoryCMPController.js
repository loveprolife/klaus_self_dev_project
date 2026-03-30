({
	initCMP: function(component,event,helper){
        component.set('v.productLineColumns', [
            { label: $A.get("$Label.c.Product_Line"), fieldName: 'productLine', type: 'text'},
            { label: $A.get("$Label.c.Sales_Quantity"), fieldName: 'quantity', type: 'text'},
            { label: $A.get("$Label.c.Total_Stock"), fieldName: 'tStock', type: 'text'},
            { label: $A.get("$Label.c.Available_Stock"), fieldName: 'aStock', type: 'text'},
            { label: $A.get("$Label.c.Stock_In_Transit"), fieldName: 'transit', type: 'text'}
        ]);
        
        var accId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        action.setParams({accId : accId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            var productLineData = [];
            for(var i=0;i<jsonData.dataList.length;i++){
                var productLine = {};
                productLine.productLine = jsonData.dataList[i].productLine;
                productLine.quantity = jsonData.dataList[i].quantity;
                productLine.tStock = jsonData.dataList[i].tStock;
                productLine.aStock = jsonData.dataList[i].aStock;
                productLine.transit = jsonData.dataList[i].transit;
                productLineData.push(productLine);
            }
            component.set("v.productLineListData",productLineData);
            component.set("v.isError",false);
        });
        $A.enqueueAction(action);
	},
})