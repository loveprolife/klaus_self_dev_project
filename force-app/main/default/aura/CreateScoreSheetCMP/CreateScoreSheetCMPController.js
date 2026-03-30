({
	initCMP: function(component,event,helper){
        component.set('v.productLineColumns', [
            { label: 'Product Line Name', fieldName: 'Product_Line_Name__c', type: 'text'},
            { label: 'Classification', fieldName: 'Classification__c', type: 'text'},
            { label: 'Development Stage', fieldName: 'Development_Stage__c', type: 'text'}
        ]);
        
        var accId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        action.setParams({accId : accId});
        action.setCallback(this, function(data) {
            jsonData = JSON.parse(data.getReturnValue());
            console.log(jsonData);
            var productLineData = [];
            for(var i=0;i<jsonData.plList.length;i++){
                var productLine = {};
                productLine.Id = jsonData.plList[i].Id;
                productLine.Product_Line_Name__c = jsonData.plList[i].Product_Line_Name__c;
                productLine.Classification__c = jsonData.plList[i].Classification__c;
                productLine.Development_Stage__c = jsonData.plList[i].Development_Stage__c;
                productLineData.push(productLine);
            }
            component.set("v.productLineListData",productLineData);
            component.set("v.isError",false);
        });
        $A.enqueueAction(action);
	},

	//选中产品线创建评分
    createScore:function(component,event,helper){
        //校验是否选中PL
        var selectedRowsCount = component.get('v.selectedRowsCount');
        if(selectedRowsCount == 0){
            component.set("v.WarningMsg",'Please select at least one line');
            component.set("v.isError",true);
            return ;
		}
		var accId = component.get("v.recordId");
        var proIdString = component.get("v.proIdString");
        var proTypeString = component.get("v.proTypeString");
        var selectPLsString = component.get("v.selectPLsString");

        //校验是否选择了同一Classification
        var proTypes = proTypeString.split(';');
        for(var i = 1; i < proTypes.length; i++)
        {
            if(proTypes[i] !== proTypes[0]){
                component.set("v.WarningMsg",'Please select same Classification to Score!');
                component.set("v.isError",true);
                return ;
            }
        }
        var action = component.get("c.getScoreInfo");
        //SC初始化参数
        action.setParams({accId : accId,classification:proTypes[0],plIds:proIdString});
        action.setCallback(this, function(data) {
            var initSC = JSON.parse(data.getReturnValue());
            console.log(initSC);
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": 'Score_Sheet__c',
                "recordTypeId": initSC.recordType,
                "defaultFieldValues": {
                    "Customer__c":accId,
                    "Status__c":initSC.status,
                    //OS
                    "Industry_Ranking__c":initSC.rank,
                    "Customer_Credit__c":initSC.customerCredit,
                    "Payment_Collection_Overdue_Times__c":initSC.paymentOverdueTimes,
                    "Customer_Relationship__c":initSC.customerRelationship,
                        //OS 老客户字段
                    "Growth_Potential__c":initSC.growthPotential,
                    "Sales_Forecast_and_Execution__c":initSC.salesForecastExecution,
                    //OEM
                    "Sales_Volume__c":initSC.salesVolumeOEM,
                    "Customer_Credit_OEM__c":initSC.customerCreditOME,
                    "Customer_Relationship_OEM__c":initSC.customerRelationshipOEM,
                    "Cooperate_with_other_product_lines_OEM__c":initSC.cooperateWithPLOEM,
                    "Growth_Potential_OEM__c":initSC.growthPotentialOEM,
                    "Sales_Forecast_and_Execution_OEM__c":initSC.salesforecastExecutionOEM,
                    
                    //AG
                    "Customer_Credit_Agency__c":initSC.customerCreditAgency,

                    //hide
                    "Product_Line__c":selectPLsString,
                    "PL_ID_List__c":proIdString
                    },
                    "navigationLocation":"LOOKUP"
                });
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                createRecordEvent.fire();
            });
            $A.enqueueAction(action);
        //document.querySelector('[title="Save & New"]').style.display = 'block';
	},
	
	updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var selectIds = [];
        var selectType = [];
        var selectPLs = [];
        for(var i=0;i<selectedRows.length;i++){
            selectIds.push(selectedRows[i].Id);
            selectType.push(selectedRows[i].Classification__c);
            selectPLs.push(selectedRows[i].Product_Line_Name__c);
        }
        var proIdString = selectIds.join(';');
        console.log('proIdString: '+ proIdString);
        component.set('v.proIdString', proIdString);

        var proTypeString = selectType.join(';');
        console.log('proTypeString: '+ proTypeString);
        component.set('v.proTypeString', proTypeString);

        var selectPLsString = selectPLs.join(';');
        console.log('selectPLsString: '+ selectPLsString);
        component.set('v.selectPLsString', selectPLsString);

        component.set('v.selectedRowsCount', selectedRows.length);
	},

	cancel: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})