({
	initCMP: function(component,event,helper){
        component.set('v.productLineColumns', [
            { label: $A.get("$Label.c.Product_Line"), fieldName: 'productLine', type: 'text'},
            { label: $A.get("$Label.c.Sample_quantity"), fieldName: 'quantity', type: 'text'},
            { label: $A.get("$Label.c.Actual_sample_quantity"), fieldName: 'realQuantity', type: 'text'},
            { label: $A.get("$Label.c.Qualified_rate_sample"), fieldName: 'sampleRate', type: 'text'}
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
                productLine.realQuantity = jsonData.dataList[i].realQuantity;
                productLine.quantity = jsonData.dataList[i].quantity;
                productLine.sampleRate = jsonData.dataList[i].sampleRate;
                productLineData.push(productLine);
            }
            component.set("v.productLineListData",productLineData);
            component.set("v.isError",false);
        });
        $A.enqueueAction(action);
	},
})