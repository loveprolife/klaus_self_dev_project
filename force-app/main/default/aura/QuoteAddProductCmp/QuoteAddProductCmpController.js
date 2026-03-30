({
	myAction: function(component,event,helper){
        var quoteId = component.get("v.recordId");
        var action = component.get("c.initData");
        var pageLabelList = $A.get("$Label.c.Quote_All_Page_Label").split('&');
        var jsonData;
        action.setParams({quoteId : quoteId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            //console.log('jsonData: '+ data.getReturnValue());
            if(jsonData.thisQuote.Approval_Status__c != 'Draft' 
            && jsonData.thisQuote.Approval_Status__c != 'Rejected'){
                component.set("v.isEditable",false);
                component.set("v.alertMessage",$A.get("$Label.c.Quote_Add_Product_With_Error_Status"));
                return ;
            }
            if(jsonData.thisQuote.Pricebook__c == null){
                component.set("v.isEditable",false);
                component.set("v.alertMessage",$A.get("$Label.c.Quote_Add_Product_Required_Price_Book"));
                return ;
            }

            var productData = [];
            var list = jsonData.productList;
            for(var i=0;i<list.length;i++){
                var productLine = {};
                productLine.Id = list[i].Id;
                productLine.Cost_Type__c = list[i].Cost_Type__c;
                productLine.Cost__c = list[i].Cost__c;

                if(list[i].Product__c != '' 
                &&  list[i].Product__c != null){
                    productLine.Name = list[i].Product__r.Name;
                    //TV产品属性
                    productLine.Screen_model__c = list[i].Product__r.Screen_model__c;
                    productLine.Panel_Model__c = list[i].Product__r.Panel_Model__c;
                    productLine.Panel_Manufacturer__c = list[i].Product__r.Panel_Manufacturer__c;
                    productLine.Movement_Model__c = list[i].Product__r.Movement_Model__c;
                    productLine.IR_Time__c = list[i].Product__r.IR_Time__c;
                    //Mobile产品属性
                    productLine.Product_Model__c = list[i].Product__r.Product_Model__c;
                    productLine.Product_Manager__c = list[i].Product__r.Product_Manager__c;
                    productLine.Energy_Efficiency_Ratio__c = list[i].Product__r.Energy_Efficiency_Ratio__c;
                    productLine.Software_android_version__c = list[i].Product__r.Software_android_version__c;

                }else if(list[i].Customer_Model_Product__c != '' 
                &&  list[i].Customer_Model_Product__c != null){
                    productLine.Name = list[i].Customer_Model_Product__r.Name;
                    if(list[i].Customer_Model_Product__r.Product_Factory_Model__c != null){
                        //TV
                        productLine.Screen_model__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Screen_model__c;
                        productLine.Panel_Model__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Panel_Model__c;
                        productLine.Panel_Manufacturer__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Panel_Manufacturer__c;
                        productLine.Movement_Model__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Movement_Model__c;
                        productLine.IR_Time__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.IR_Time__c;
                    }
                }
                

                productData.push(productLine);
            }
            var currencyType = '';
            if(list.length > 0){
                currencyType = list[0].CurrencyIsoCode;
            } 
            console.log('currencyType: '+currencyType);
            if(jsonData.productLinePicklists[0].value == 'TV'){
                component.set('v.productColumns', [
                    { label: pageLabelList[2], fieldName: 'Name', type: 'text'},
                    { label: pageLabelList[4], fieldName: 'Cost_Type__c', type: 'text'},
                    // { label: pageLabelList[5], fieldName: 'Cost__c', type: 'currency',typeAttributes: { currencyCode: currencyType}},
                    { label: pageLabelList[6], fieldName: 'Screen_model__c', type: 'text'},
                    { label: pageLabelList[7], fieldName: 'Panel_Model__c', type: 'text'},
                    { label: pageLabelList[8], fieldName: 'Panel_Manufacturer__c', type: 'currency',typeAttributes: { currencyCode: currencyType}},
                    { label: pageLabelList[9], fieldName: 'Movement_Model__c', type: 'text'},
                    { label: pageLabelList[10], fieldName: 'IR_Time__c', type: 'text'}
                ]);
            }else{
                component.set('v.productColumns', [
                    { label: pageLabelList[2], fieldName: 'Name', type: 'text'},
                    { label: pageLabelList[4], fieldName: 'Cost_Type__c', type: 'text'},
                    //{ label: 'Cost', fieldName: 'Cost__c', type: 'currency',typeAttributes: { currencyCode: currencyType}}
                ]);    
            }
            component.set("v.isEditable",true);
            component.set("v.pageLabelList",pageLabelList);
            component.set("v.productLinePicklists",jsonData.productLinePicklists);
            component.set("v.productStatusPicklists",jsonData.productStatusPicklists);
            component.set("v.deliveryFormPicklists",jsonData.deliveryFormPicklists);
            component.set("v.costTypePicklists",jsonData.costTypePicklists);
            component.set("v.productListData",productData);
            component.set("v.thisQuote",jsonData.thisQuote);
            component.set('v.labelL',jsonData.productLinePicklists[0].value);
        });
        $A.enqueueAction(action);

        
	},
    //搜索产品
	searchProduct: function(component,event,helper){
		console.log('searchProduct');
		var quoteId = component.get("v.recordId");
        var pageLabelList = component.get("v.pageLabelList");
        var selectedProLine = component.get("v.labelL");
		var t=[];
        t.push(selectedProLine);
		var n = document.querySelector('input[name="nameInput"]').value;
		var action = component.get("c.getSearchResultList");
		var list;
		action.setParams({
			quoteId : quoteId,
			proLineList : t,
			proName: n
		});
		action.setCallback(this, function(data) {
			list =  data.getReturnValue();
            var productData = [];
		    for(var i=0;i<list.length;i++){
                var productLine = {};
                productLine.Id = list[i].Id;
                productLine.Cost_Type__c = list[i].Cost_Type__c;
                productLine.Cost__c = list[i].Cost__c;
                if(list[i].Product__c != '' &&  list[i].Product__c != null){
                    productLine.Name = list[i].Product__r.Name;
                    //TV
                    productLine.Screen_model__c = list[i].Product__r.Screen_model__c;
                    productLine.Panel_Model__c = list[i].Product__r.Panel_Model__c;
                    productLine.Panel_Manufacturer__c = list[i].Product__r.Panel_Manufacturer__c;
                    productLine.Movement_Model__c = list[i].Product__r.Movement_Model__c;
                    productLine.IR_Time__c = list[i].Product__r.IR_Time__c;
                    //Mobile
                    productLine.Product_Model__c = list[i].Product__r.Product_Model__c;
                    productLine.Product_Manager__c = list[i].Product__r.Product_Manager__c;
                    productLine.Energy_Efficiency_Ratio__c = list[i].Product__r.Energy_Efficiency_Ratio__c;
                    productLine.Software_android_version__c = list[i].Product__r.Software_android_version__c;
                }else if(list[i].Customer_Model_Product__c != '' &&  list[i].Customer_Model_Product__c != null){
                    productLine.Name = list[i].Customer_Model_Product__r.Name;
                    if(list[i].Customer_Model_Product__r.Product_Factory_Model__c != null){
                        //TV
                        productLine.Screen_model__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Screen_model__c;
                        productLine.Panel_Model__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Panel_Model__c;
                        productLine.Panel_Manufacturer__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Panel_Manufacturer__c;
                        productLine.Movement_Model__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.Movement_Model__c;
                        productLine.IR_Time__c = list[i].Customer_Model_Product__r.Product_Factory_Model__r.IR_Time__c;
                    }
                    
                }
                productData.push(productLine);
		    }
            var currencyType = '';
            if(list.length > 0){
                currencyType = list[0].CurrencyIsoCode;
            } 
            if(selectedProLine == 'TV'){
                component.set('v.productColumns', [
                    { label: pageLabelList[2], fieldName: 'Name', type: 'text'},
                    { label: pageLabelList[4], fieldName: 'Cost_Type__c', type: 'text'},
                    // { label: pageLabelList[5], fieldName: 'Cost__c', type: 'currency',typeAttributes: { currencyCode: currencyType}},
                    { label: pageLabelList[6], fieldName: 'Screen_model__c', type: 'text'},
                    { label: pageLabelList[7], fieldName: 'Panel_Model__c', type: 'text'},
                    { label: pageLabelList[8], fieldName: 'Panel_Manufacturer__c', type: 'currency',typeAttributes: { currencyCode: currencyType}},
                    { label: pageLabelList[9], fieldName: 'Movement_Model__c', type: 'text'},
                    { label: pageLabelList[10], fieldName: 'IR_Time__c', type: 'text'}
                ]);
            }else{
                component.set('v.productColumns', [
                    { label: pageLabelList[2], fieldName: 'Name', type: 'text'},
                    { label: pageLabelList[4], fieldName: 'Cost_Type__c', type: 'text'},
                    //{ label: 'Cost', fieldName: 'Cost__c', type: 'currency',typeAttributes: { currencyCode: currencyType}}
                ]);   
            }
			component.set("v.productListData",productData);
		});
		$A.enqueueAction(action);
	},
    updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var selectIds = [];
        for(var i=0;i<selectedRows.length;i++){
            selectIds.push(selectedRows[i].Id);
        }
        var proIdString = selectIds.join(';');
        console.log('proIdString: '+ proIdString);
        component.set('v.proIdString', proIdString);
        component.set('v.selectedRowsCount', selectedRows.length);
    },
    //选中产品后保存
    selectSubmit:function(component,event,helper){
        console.log('selectSubmit');
        var isSaved = component.get("v.isSaved");
        var selectedRowsCount = component.get('v.selectedRowsCount');
        if(selectedRowsCount == 0){
            // alert('Please select at least one line');
            alert($A.get("$Label.c.Quote_Add_Product_At_Least_Select_One_Line"));
            return ;
        }
        //避免重复点击保存按钮后重复保存
        if(isSaved){
            return ;
        }
        component.set("v.isSaved",true);
        var quoteId = component.get("v.recordId");
        var proIdString = component.get("v.proIdString");
        var action = component.get("c.saveSelectedProList");
        action.setParams({
            proIdString : proIdString,
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
    //修改产品
    productChange:function(component,event,helper){
        var index = event.getSource().get("v.id");
        component.get('v.productListData')[index].Product__c = event.getSource().get('v.value');
    },
    //保存产品
    saveProduct:function(component,event,helper){
        var saveData = {};
        var savelist = [];
        var isSaved = component.get("v.isSaved");
        var quoteId = component.get("v.recordId");
        var datalist = component.get("v.selectedProductListData");
        //console.log('datalist---->>>>>' +JSON.stringify(datalist));
        var errMessage = '';
        //避免重复点击保存按钮后重复保存
        if(isSaved){
            return ;
        }

        component.set("v.isSaved",true);
        var action = component.get("c.saveQuoteProduct");
        action.setParams({
            productList : datalist
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
    //返回产品选择页面
	assignBack:function(component,event,helper){
		console.log('assignBack');
        component.set('v.selectedRowsCount', 0);
        component.set("v.isShowEdit",false);
	},
    //删除产品行
    removeDeletedRow:function(component,event,helper){
        var index = event.getSource().get("v.id");
        var selectedProductListData = component.get("v.selectedProductListData");
        selectedProductListData.splice(index,1);
        component.set("v.selectedProductListData",selectedProductListData);         
    },
    //关闭窗口
	assignCancel:function(component,event,helper){
		$A.get("e.force:closeQuickAction").fire();
	}
})