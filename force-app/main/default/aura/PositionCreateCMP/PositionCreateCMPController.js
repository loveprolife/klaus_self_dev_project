({
    init: function (component, event, helper) {
        component.set("v.showWaiting", true);
        // helper.addNewRowInit(component, event);
        // helper.setShopHistory(component, event);
        var recordId = component.get("v.recordId");
        var initAction = component.get("c.initGridding");
        var shopSearch = new Object();
        shopSearch.shopName = '';
        shopSearch.accountName = '';
        shopSearch.griddingName = '';
        component.set('v.shopSearch', shopSearch);
        initAction.setParams({
            "recordId": recordId
        });
        initAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result.success) {
                    // component.set('v.gridColumns', result.columHeader);
                    // component.set('v.gridData', result.gridData);
                    component.set('v.gridNewColumns', result.gridNewColumns);
                    component.set('v.productLineList', result.productLineList);
                    component.set('v.gridMap', result.gridMap);

                    //业务数据
                    component.set('v.gridSelectedRows', result.currentPermissionsGridDataList);
                    component.set('v.gridSelectedRowsCollapse', result.currentPermissionsGridDataList);
                    component.set('v.accProductLineList', result.accProductLineList);
                    component.set('v.shopItemList', result.shopItemList);
                    // wfc
                    component.set('v.userList', result.userList);
                    // this.expandAllRows(component, event, helper);
                    // var tree = component.find('asyncBomTreeId');
                    // tree.expandAll();
                    component.set("v.showWaiting", false);
                } else {
                    helper.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                helper.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(initAction);
    },

    handleActive: function (component, event, helper) {
        
    },

    expandAllRows: function (component, event, helper) {
        var gridSelectedRowsCollapse = component.get("v.gridSelectedRowsCollapse");
        var tree = component.find('asyncBomTreeId');
        tree.expandAll();
        component.set('v.gridSelectedRows', gridSelectedRowsCollapse);
    },

    collapseAllRows: function (component, event, helper) {
        var gridSelectedRows = component.get("v.gridSelectedRows");
        var tree = component.find('asyncBomTreeId');
        tree.collapseAll();
        component.set('v.gridSelectedRows', gridSelectedRows);
    },

    // onrowselection: function (component, event, helper) {
    //     if (!component.get('v.bypassOnRowSelection')) {
    //         component.set("v.showWaiting", true);

    //         //当前组件中选择的数据Id
    //         var gridSelectedRowsTemp = [];
    //         var theTree = component.find('asyncBomTreeId');
    //         var currentExpandedRows = theTree.getCurrentExpandedRows();
    //         var choiceTreeList = theTree.getSelectedRows();
    //         for (let index = 0; index < choiceTreeList.length; index++) {
    //             var rowsKey = choiceTreeList[index].key;
    //             gridSelectedRowsTemp.push(rowsKey);
    //         }
    //         //当前后台保存的数据
    //         var gridSelectedRowsCollapse = component.get("v.gridSelectedRowsCollapse");
    //         console.log(" gridSelectedRowsTemp " + JSON.stringify(gridSelectedRowsTemp));
    //         console.log(" gridSelectedRowsCollapse " + JSON.stringify(gridSelectedRowsCollapse));

    //         //获取当前选中/取消选中的数据
    //         var selectId;
    //         var isInsert = true;
    //         if (gridSelectedRowsCollapse.length < gridSelectedRowsTemp.length) {
                
    //             //选中Id
    //             for (var i = 0; i < gridSelectedRowsTemp.length; i++) {
    //                 var currentId = gridSelectedRowsTemp[i];
    //                 console.log(" currentId " + currentId);
    //                 var indexVal = gridSelectedRowsCollapse.indexOf(currentId, 0);
    //                 if (indexVal == -1) {
    //                     selectId = currentId;
    //                 }
    //             }
    //             console.log("进入Insert " + selectId);

    //             isInsert = true;
    //         } else {
    //             //取消选中
    //             for (var j = 0; j < gridSelectedRowsCollapse.length; j++) {
    //                 var unCurrentId = gridSelectedRowsCollapse[j];
    //                 var unIndexVal = gridSelectedRowsTemp.indexOf(unCurrentId, 0);
    //                 if (unIndexVal == -1) {
    //                     selectId = unCurrentId;
    //                 }
    //             }
    //             console.log("进入delete " + selectId);
    //             isInsert = false;
    //         }

            
    //         var recordId = component.get("v.recordId");
    //         var gridData = component.get("v.gridData");
    //         var action = component.get("c.createGridding");
    //         action.setParams({
    //             "recordId": recordId,
    //             "griddingId": selectId,
    //             "actionType": isInsert ? "insert" : "delete",
    //             "gridSelectedRowsTemp": gridSelectedRowsTemp,
    //             "gridData": gridData
    //         });
    //         action.setCallback(this, function (response) {
    //             var state = response.getState();
    //             var result = response.getReturnValue();

    //             if (state === 'SUCCESS') {
    //                 if (result.success) {
    //                     component.set('v.gridSelectedRows', result.currentPermissionsGridDataList);
    //                     component.set('v.gridSelectedRowsCollapse', result.currentPermissionsGridDataList);
    //                     // component.set('v.expandedRowsCount', result.currentPermissionsGridDataList.length);
    //                     component.set("v.showWaiting", false);
    //                 } else {
    //                     helper.showModal(component, event, 'Error', result.message, "error");
    //                     component.set("v.showWaiting", false);
    //                 }
    //             } else {
    //                 helper.showModal(component, event, 'Error', response.getErrors(), "error");
    //                 component.set("v.showWaiting", false);
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     }
    //     component.set('v.bypassOnRowSelection', false);
    // },

    testFunction: function (component, event, helper) {
        console.log("testFunction");
       
    },

    onRowToggle: function (component, event, helper) {
        var treeGridComponent = component.find("asyncBomTreeId");
        treeGridComponent.expandAll();
        if (treeGridComponent) {

            //当前打开的行数 currentExpandedRows
            var currentExpandedRows = treeGridComponent.getCurrentExpandedRows();

            if (currentExpandedRows && currentExpandedRows.length != null && currentExpandedRows.length != undefined) {
                if (currentExpandedRows.length >= component.get('v.expandedRowsCount')) {
                    var gridSelectedRowsCollapseIds = [];
                    var gridSelectedRowsCollapse = component.get('v.gridSelectedRowsCollapse');
                    if (gridSelectedRowsCollapse && gridSelectedRowsCollapse.length > 0) {
                        for (var i = 0; i < gridSelectedRowsCollapse.length; i++) {
                            gridSelectedRowsCollapseIds.push(gridSelectedRowsCollapse[i]);
                        }
                    }
                    console.log("gridSelectedRowsCollapseIds" + gridSelectedRowsCollapseIds.length);
                    component.set('v.gridSelectedRows', gridSelectedRowsCollapseIds);
                    var gridSelectedRowsCollapse = component.get("v.gridSelectedRowsCollapse");
                    component.set('v.gridSelectedRows', gridSelectedRowsCollapse);
                    component.set('v.gridSelectedRowsCollapse', gridSelectedRowsCollapse);
                    component.set('v.bypassOnRowSelection', false);
                    // this.onrowselection(component, event, helper);
                    component.set('v.expandedRowsCount', currentExpandedRows.length);
                } else {
                    component.set('v.bypassOnRowSelection', true);
                }
                component.set('v.expandedRowsCount', currentExpandedRows.length);
            }
        }
    },

    addNewRowAccProductLine: function (component, event, helper) {
        component.set("v.showWaiting", true);
        helper.addNewRow(component, event);
    },

    changeAccount: function (component, event, helper) {
        component.set("v.showWaiting", true);
        // 客户Id
        var accRecordId = event.getSource().get("v.value");

        //客户产品线数据
        var accProductLineList = component.get("v.accProductLineList");

        //当前操作行Index
        var currentRowIndex = event.getSource().get("v.class");
        var isReturn = false;
        console.log("currentRowIndex" + currentRowIndex);
        if (accRecordId != "" && accRecordId != null) { 
            for (var i = 0; i < accProductLineList.length; i++) {
                if (accRecordId == accProductLineList[i].accId) { 
                    helper.showModal(component, event, 'warning', "该客户已存在,不可创建重复客户", "warning");
                    isReturn = true;
                }
            }
        }

        if (isReturn) { 
            window.setTimeout(function(){
                accProductLineList[currentRowIndex].accId = [];
                component.set("v.accProductLineList", accProductLineList);
                component.set("v.showWaiting", false);
            }, 2000);
        }

        if (!isReturn) { 
            for (var i = 0; i < accProductLineList.length; i++) {
                if (!!accProductLineList[i].accId) {
                    if (Object.prototype.toString.call(accProductLineList[i].accId) !== "[object String]") {
                        accProductLineList[i].accId = accProductLineList[i].accId[0];
                    }
                } else {
                    accProductLineList[i].accId = null;
                }
            }
    
            helper.changeAccountHelper(component, event, accRecordId + '', JSON.stringify(accProductLineList));
        }
    },

    onCheck: function (component, event, helper) {
        component.set("v.showWaiting", true);
        var checkOutValue = event.getSource().get("v.value");
        console.log("checkOutValue " + checkOutValue);

        var accProductLineKey = event.getSource().get("v.name");
        console.log("accProductLineKey " + accProductLineKey);

        //客户产品线数据
        var accProductLineList = component.get("v.accProductLineList");

        for (var i = 0; i < accProductLineList.length; i++) {
            if (!!accProductLineList[i].accId) {
                if (Object.prototype.toString.call(accProductLineList[i].accId) !== "[object String]") {
                    accProductLineList[i].accId = accProductLineList[i].accId[0];
                }
            } else {
                accProductLineList[i].accId = null;
            }
        }

        helper.onCheckProductLine(component, event, checkOutValue, accProductLineKey, accProductLineList);
    },

    deleteRow: function (component, event, helper) { 
        component.set("v.showWaiting", true);

        //当前删除行Index
        // var currentDeleteRowIndex = event.target.name;
        var currentDeleteRowIndex = event.currentTarget.name;

        //客户产品线数据
        var accProductLineList = component.get("v.accProductLineList");

        //当前删除数据的Account Id
        var accId = accProductLineList[currentDeleteRowIndex].accId;

        console.log("accId " + accId);
        if (accId == null || accId == "") {
            console.log("accId为空");
            accProductLineList.splice(currentDeleteRowIndex, 1);
            component.set("v.accProductLineList", accProductLineList);
            component.set("v.showWaiting", false);
        } else { 
            console.log("accId不为空");
            helper.deleteRowHelper(component, event, currentDeleteRowIndex, accId, accProductLineList);
        }
    },

    searchDataHelper: function (component, event, helper) { 
        component.set("v.showWaiting", true);

        var shopSearch = component.get("v.shopSearch");
        console.log("shopSearch " + JSON.stringify(shopSearch));
        helper.searchShopHelper(component, event, shopSearch);
    },

    chooseShop: function (component, event, helper) {
        component.set("v.showWaiting", true);
        var currentShop = event.getSource().get("v.value");
        helper.chooseShopHelper(component, event, currentShop);
    },

    unChooseShop : function (component, event, helper) {
        component.set("v.showWaiting", true);
        var currentShop = event.getSource().get("v.value");
        helper.unChooseShopHelper(component, event, currentShop);
    },

    showOrHideChildrenRows: function (component, event, helper) { 
        component.set("v.showWaiting", true);
        var currentId = event.target.name;
        var currentgridNewColumns = component.get("v.gridNewColumns");
        console.log("currentId :" + currentId);
        var currentIconName;
        var currentName;
        for (let i = 0; i < currentgridNewColumns.length; i++) { 
            if (currentgridNewColumns[i].recordId == currentId) { 
                console.log("currentgridNewColumns[i].iconName" + currentgridNewColumns[i].iconName);
                currentIconName = currentgridNewColumns[i].iconName;
                currentName = currentgridNewColumns[i].Name;
            }
        }

        var openOrCloseGriddingAction = component.get("c.openOrCloseGridding");
        openOrCloseGriddingAction.setParams({
            "currentgridNewColumnsJson": JSON.stringify(currentgridNewColumns),
            "currentId": currentId,
            "currentIconName": currentIconName,
            "currentName" : currentName
        });
        openOrCloseGriddingAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                component.set("v.showWaiting", false);
                component.set("v.gridNewColumns", result);
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(openOrCloseGriddingAction);
    },

    onCheckGridding: function (component, event, helper) {
        component.set("v.showWaiting", true);
        var currentValue = event.getSource().get("v.value");
        var currentGridding = event.getSource().get("v.name");
        console.log("currentValue" + currentValue);
        console.log("currentGridding" + currentGridding);

        helper.onCheckGriddingHelper(component, event, currentValue, currentGridding);
    }
})