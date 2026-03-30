({
	initCMP: function(component,event,helper){
        

        var accId = component.get("v.recordId");
        var action = component.get("c.initDetail");
        var jsonData;
        action.setParams({accId : accId});
        action.setCallback(this, function(data) {
            console.log('detaildata' + data.getReturnValue());
            jsonData = JSON.parse(data.getReturnValue());
            console.log('detailjsonData' + jsonData);
            var productLineData = [];
            for(var i=0;i<jsonData.detailList.length;i++){
                var productLine = {};
                productLine.create_dt = jsonData.detailList[i].create_dt;
                productLine.productLine = jsonData.detailList[i].productLine;
                productLine.cust_model = jsonData.detailList[i].cust_model;
                productLine.act_qty = jsonData.detailList[i].act_qty;
                productLine.Tot_SOH = jsonData.detailList[i].Tot_SOH;
                productLine.Avl_SOH = jsonData.detailList[i].Avl_SOH;
                // productLine.st_intr = jsonData.detailList[i].st_intr;
                productLine.Supportable_Days = jsonData.detailList[i].Supportable_Days;
                productLine.Stock_Status = jsonData.detailList[i].Stock_Status;
                productLineData.push(productLine);
            }
            component.set("v.productLineListData",productLineData);
            component.set("v.isError",false);
        });
        $A.enqueueAction(action);
	},
})