({
	myAction : function(component, event, helper) {
		var quoteId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        var productList = [];
        action.setParams({quoteId : quoteId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            for(var i=0;i<jsonData.productList.length;i++){
                var productItem = {};
                productItem.Id = jsonData.productList[i].Id;
                productItem.Product__c = jsonData.productList[i].Product__c;
                productItem.Product_Name_Formula__c = jsonData.productList[i].Product_Name_Formula__c;
                productItem.Cost_Type__c = jsonData.productList[i].Cost_Type__c;
                productItem.Cost__c = jsonData.productList[i].Cost__c;
                productItem.Unit_Sell_In_Price__c = jsonData.productList[i].Unit_Sell_In_Price__c;
                productItem.Quantity__c = jsonData.productList[i].Quantity__c;
                productItem.Product_Status__c = jsonData.productList[i].Product_Status__c;        
                productItem.Remark__c = jsonData.productList[i].Remark__c;
                productItem.Delivery_Form__c = jsonData.productList[i].Delivery_Form__c;
                productItem.Delivery_Form_Fee__c = jsonData.productList[i].Delivery_Form_Fee__c;
                productItem.Estimatied_Delivery_Date__c = jsonData.productList[i].Estimatied_Delivery_Date__c;
                productItem.Royalties__c = jsonData.productList[i].Royalties__c;
                productItem.Need_to_Provide_EXW__c = jsonData.productList[i].Need_to_Provide_EXW__c;
                productList.push(productItem);
            };
            component.set("v.productStatusPicklists",jsonData.productStatusPicklists);
            component.set("v.deliveryFormPicklists",jsonData.deliveryFormPicklists);
            component.set("v.costTypePicklists",jsonData.costTypePicklists);
            component.set("v.productListData",productList);
            component.set("v.thisQuote",jsonData.thisQuote);  
            component.set("v.currentUser",jsonData.currentUser);    
        });
        $A.enqueueAction(action);
	},
    //修改产品
    productChange:function(component,event,helper){
        var index = event.getSource().get("v.id");
        component.get('v.productListData')[index].Product__c = event.getSource().get('v.value');
    },
	//保存产品
    saveProduct:function(component,event,helper){
        var isSaved = component.get("v.isSaved");
        var quoteId = component.get("v.recordId");
        var datalist = component.get("v.productListData");
        var errMessage = '';
        //避免重复点击保存按钮后重复保存
        if(isSaved){
            return ;
        }
        component.set("v.isSaved",true);
        var action = component.get("c.saveQuoteProduct");
        console.log('datalist---->>>>>' +JSON.stringify(datalist));
        action.setParams({
            productList : datalist,
            quoteId : quoteId
        });
        action.setCallback(this, function(data) {
            var saveMessage =  data.getReturnValue();
            if(saveMessage == 'SUCCESS'){
                component.set("v.isSaved",true);
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }else{
                alert(saveMessage);
                component.set("v.isSaved",false);
                return;
            }
        });
        $A.enqueueAction(action);
    },
    //删除产品行
    removeDeletedRow:function(component,event,helper){
        var index = event.getSource().get("v.id");
        var productListData = component.get("v.productListData");
        productListData.splice(index,1);
        component.set("v.productListData",productListData);         
    },
    //关闭窗口
	assignCancel:function(component,event,helper){
		$A.get("e.force:closeQuickAction").fire();
	}
})