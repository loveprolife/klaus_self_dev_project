({
	myAction: function(component,event,helper){
        var oppId = component.get("v.recordId");
        var action = component.get("c.initData");
        var pageLabelList = $A.get("$Label.c.Opportunity_All_Page_Label").split('&');
        var jsonData;
        action.setParams({oppId : oppId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            var productData = [];
            component.set('v.productColumns', [
                { label: pageLabelList[2], fieldName: 'Name', type: 'text'}
            ]);
            component.set("v.pageLabelList",pageLabelList);
            component.set("v.productLinePicklists",jsonData.productLinePicklists);
            component.set("v.productStatusPicklists",jsonData.productStatusPicklists);
            component.set("v.productListData",jsonData.productList);
            component.set("v.thisOpp",jsonData.thisOpp);
            component.set('v.labelL',jsonData.productLinePicklists[0].value);
        });
        $A.enqueueAction(action);

        
	},
    //搜索产品
	searchProduct: function(component,event,helper){
		console.log('searchProduct');
		var oppId = component.get("v.recordId");
        var selectedProLine = component.get("v.labelL");
		var t=[];
        t.push(selectedProLine);
		var n = document.querySelector('input[name="nameInput"]').value;
		var action = component.get("c.getSearchResultList");
		var list;
		action.setParams({
			oppId : oppId,
			proLineList : t,
			proName: n
		});
		action.setCallback(this, function(data) {
			list =  data.getReturnValue();
			component.set("v.productListData",list);
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
    //选中产品后进行编辑
    selectSubmit:function(component,event,helper){
        console.log('selectSubmit');
        var selectedRowsCount = component.get('v.selectedRowsCount');
        if(selectedRowsCount == 0){
            // alert('Please select at least one line');
            alert($A.get("$Label.c.Opportunity_Add_Product_At_Least_Select_One_Line"));
            return ;
        }
        var oppId = component.get("v.recordId");
        var proIdString = component.get("v.proIdString");
        var action = component.get("c.getSelectedProList");
        action.setParams({
            proIdString : proIdString,
            oppId : oppId
        });
        action.setCallback(this, function(data) {
            var list =  data.getReturnValue();
            component.set("v.isShowEdit",true);
            component.set("v.selectedProductListData",list);
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
        var pageLabelList = component.get("v.pageLabelList");
        var datalist = component.get("v.selectedProductListData");
        console.log('datalist---->>>>>' +JSON.stringify(datalist));
        var errMessage = '';
        //避免重复点击保存按钮后重复保存
        if(isSaved){
            return ;
        }
   
        component.set("v.isSaved",true);
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
        };
        if(errMessage.indexOf($A.get("$Label.c.Quote_Product_Field_Require_Alert")) > 0){
            alert(errMessage);
            component.set("v.isSaved",false);
            return;
        }
        var action = component.get("c.saveOppProduct");
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