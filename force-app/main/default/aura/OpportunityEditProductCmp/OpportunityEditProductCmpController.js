({
	myAction : function(component, event, helper) {
		var oppId = component.get("v.recordId");
        var action = component.get("c.initData");
        var pageLabelList = $A.get("$Label.c.Opportunity_All_Page_Label").split('&');
        var jsonData;
        action.setParams({oppId : oppId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            // console.log('jsonData.productList---->>>>>' +JSON.stringify(jsonData.productList));
            component.set("v.pageLabelList",pageLabelList);
            component.set("v.productStatusPicklists",jsonData.productStatusPicklists);
            component.set("v.productListData",jsonData.productList);
            component.set("v.thisQuote",jsonData.thisQuote);
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
        var oppId = component.get("v.recordId");
        var pageLabelList = component.get("v.pageLabelList");
        var datalist = component.get("v.productListData");
        // console.log('datalist---->>>>>' +JSON.stringify(datalist));
        var errMessage = '';
        //避免重复点击保存按钮后重复保存
        if(isSaved){
            return ;
        }
        component.set("v.isSaved",true);
        var productList = [];
        var errMessage = '';
        for(var i=0;i<datalist.length;i++){
            var lineErrCount = 0;
        	var proName = '[' + datalist[i].Product__r.Name + ']';
        	errMessage += proName;
            if(datalist[i].Quantity__c == null){
                errMessage += ' ' + pageLabelList[7] + ',';
                lineErrCount++;
            }
            if(datalist[i].Product_Status__c == null
            || datalist[i].Product_Status__c == ''){
                errMessage += ' ' + pageLabelList[8] + ',';
                lineErrCount++;
            }
            if(lineErrCount > 0){
                errMessage = errMessage.substring(0,errMessage.length-1);
                errMessage += ' ' + $A.get("$Label.c.Quote_Product_Field_Require_Alert") + '\n';
                continue;
            }else{
                // console.log('errMessage---->>>>>' +errMessage);
                errMessage = errMessage.replace(proName,'');
            }
            var productItem = {};
            productItem.Id = datalist[i].Id;
            productItem.Quantity__c = datalist[i].Quantity__c;
            productItem.Product_Status__c = datalist[i].Product_Status__c;        
            productItem.Remark__c = datalist[i].Remark__c;
            productList.push(productItem);
        };
        if(errMessage.indexOf($A.get("$Label.c.Quote_Product_Field_Require_Alert")) > 0){
            alert(errMessage);
            component.set("v.isSaved",false);
			return;
        }
        var action = component.get("c.saveOppProduct");
        action.setParams({
            productList : productList,
            oppId : oppId
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