({
    showModal: function(component, evt, title, message, msgType) {
        var toast = $A.get("e.force:showToast");
        toast.setParams({ 
            "title" : title,
            "message" : message,
            "type" : msgType,
            "mode" : "dismissible",
            "duration" : "5000"
        }); 
        toast.fire();
    },

    addChildrenToRow: function(originalData, rowKey, children) {
        var that = this;
        var newData = originalData.map(function(row) {
            var hasChildrenContent = false;
            if (row.hasOwnProperty('_children') && Array.isArray(row._children) && row._children.length > 0) {
                hasChildrenContent = true;
            }

            if (row.key === rowKey) {
                row.expanded = 'Y';
                row._children = children;
            } else if (hasChildrenContent) {
                that.addChildrenToRow(row._children, rowKey, children);
            }

            return row;
        });

        return newData;
    },

    updateRowExpandedFlag: function(originalData, rowKey) {
        var that = this;
        var newData = originalData.map(function(row) {
            var hasChildrenContent = false;
            if (row.hasOwnProperty('_children') && Array.isArray(row._children) && row._children.length > 0) {
                hasChildrenContent = true;
            }

            if (row.key === rowKey) {
                row.expanded = 'Y';
            } else if (hasChildrenContent) {
                that.updateRowExpandedFlag(row._children, rowKey);
            }

            return row;
        });

        return newData;
    },

    addNewRowInit : function(component, event){
        var obj = {};
        var accProductLineList = component.get("v.accProductLineList");
        accProductLineList.push(obj);
        component.set("v.accProductLineList", accProductLineList);
        component.set("v.showWaiting", false);
    },

    addNewRow : function(component, event){

        var action = component.get("c.addNewRow");
        var accProductLineList = component.get("v.accProductLineList");

        action.setParams({
            "objStr" : JSON.stringify(accProductLineList)
        });
        action.setCallback(this, function (response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state == "SUCCESS") {
                component.set("v.accProductLineList", result);
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(action);
    },

    setShopHistory : function(component, event) { 
        // var obj = {};
        // obj.shopName = "Homeplus本石町店";
        // obj.shopId = "a1c0T000000Oe1ZQAS";
        // var globalSelectedItems = component.get("v.globalSelectedItems");
        // globalSelectedItems.push(obj);
        // component.set("v.globalSelectedItems", globalSelectedItems);

        var gridNewColumns = [
                {
                    name: "United States",
                    recordId: "1",
                    iconName: "utility:chevronright",
                    parentId : "",
                    rowStyle : true,
                    nameStyle: "",
                    isChoose : false
                },
                {
                    name: "Massachusetts",
                    recordId: "2",
                    iconName: "utility:chevronright",
                    parentId: "1",
                    rowStyle : false,
                    nameStyle: "margin-left:10px;",
                    isChoose : false
                },
                {
                    name: "Boston",
                    recordId: "3",
                    iconName: "utility:chevronright",
                    parentId: "2",
                    rowStyle : false,
                    nameStyle: "margin-left:20px;",
                    isChoose : false
                },              
                {
                    name: "New York",
                    recordId: "4",
                    iconName: "utility:chevronright",
                    parentId : "1",
                    rowStyle : false,
                    nameStyle: "margin-left:10px;",
                    isChoose : false
                },
                {
                    name: "Vatican City",
                    recordId : "5",
                    iconName: "utility:chevronright",
                    parentId : "",
                    rowStyle : true,
                    nameStyle: "",
                    isChoose : false
                },
                {
                    name: "Canada",
                    recordId : "6",
                    iconName: "utility:chevronright",
                    parentId : "",
                    rowStyle : true,
                    nameStyle: "",
                    isChoose : false
                },
                {
                    name: "Ontario",
                    recordId : "7",
                    iconName: "utility:chevronright",
                    parentId : "6",
                    rowStyle : false,
                    nameStyle: "margin-left:10px;",
                    isChoose : false
                },
                {
                    name: "Alberta",
                    recordId :"8",
                    iconName: "utility:chevronright",
                    parentId : "6",
                    rowStyle : false,
                    nameStyle: "margin-left:10px;",
                    isChoose : false
                }
        ];
        
        component.set('v.gridNewColumns', gridNewColumns);
    },

    changeAccountHelper: function (component, event, accRecordId, accProductLineListJSON) { 
        var changeAccaction = component.get("c.changeAccoutFunction");
        changeAccaction.setParams({
            "accId": accRecordId,
            "accProductLineListJSON": accProductLineListJSON,
            "recordId" : component.get('v.recordId')
        });
        changeAccaction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                component.set('v.accProductLineList', result);
                component.set("v.showWaiting", false);
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
            component.set("v.showWaiting", false);
        });
        $A.enqueueAction(changeAccaction);
    },

    onCheckProductLine: function (component, event, checkOutValue, accProductLineKey, accProductLineList) { 
        var checkProductLineAction = component.get("c.checkProductLine");
        checkProductLineAction.setParams({
            "checkOutValue" : checkOutValue,
            "accProductLineKey" : accProductLineKey,
            "accProductLineList": accProductLineList,
            "positionId": component.get("v.recordId")
        });
        checkProductLineAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result.success) {
                    component.set("v.showWaiting", false);
                } else { 
                    //发生错误是,将checkOutValue值为相反数
                    component.set('v.accProductLineList', result.accProductLineList);
                    this.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
            component.set("v.showWaiting", false);
        });
        $A.enqueueAction(checkProductLineAction);
    },

    deleteRowHelper: function (component, event, currentDeleteRowIndex, accId, accProductLineList) { 
        console.log("Into deleteRowHelper");
        var recordId = component.get("v.recordId");
        var deleteRowAction = component.get("c.deleteRowLine");
        deleteRowAction.setParams({
            "accRecordId": accId + "",
            "recordId" : recordId
        });
        deleteRowAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result.success) {
                    accProductLineList.splice(currentDeleteRowIndex, 1);
                    component.set("v.accProductLineList", accProductLineList);
                    component.set("v.showWaiting", false);
                } else { 
                    this.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(deleteRowAction);
    },

    searchShopHelper: function (component, event, shopSearch) { 
        var searchAction = component.get("c.searchActionFunction");
        var noIncludingGridIdList = [];
        var shopItemList = component.get("v.shopItemList");
        for (var i = 0; i < shopItemList.length; i++) {
            noIncludingGridIdList.push(shopItemList[i].shopExternalKeyID);
        }

        console.log("noIncludingGridIdList " + JSON.stringify(noIncludingGridIdList));
        searchAction.setParams({
            "shopSearchMap": shopSearch,
            "noIncludingGridIdList" : noIncludingGridIdList
        });
        searchAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result.success) {
                    component.set("v.shopSearchList", result.shopSearchItemList);
                    component.set("v.showWaiting", false);
                } else { 
                    this.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(searchAction);
    },

    chooseShopHelper: function (component, event, currentShop) { 
        var chooseShopAction = component.get("c.chooseShopFunction");
        var recordId = component.get("v.recordId");
        var shopSearchList = component.get("v.shopSearchList");
        chooseShopAction.setParams({
            "currentShopId" : currentShop,
            "recordId" : recordId,
            "shopSearchListJSON": JSON.stringify(shopSearchList),
            "shopListJSON": JSON.stringify(component.get("v.shopItemList"))
        });
        chooseShopAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result.success) {
                    component.set("v.shopSearchList", result.shopSearchItemList);
                    component.set("v.shopItemList", result.shopItemList);
                    component.set("v.showWaiting", false);
                } else { 
                    this.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(chooseShopAction);
    },

    unChooseShopHelper: function (component, event, currentShop) { 
        var unChooseShopAction = component.get("c.unChooseShopFunction");
        var recordId = component.get("v.recordId");
        var shopSearchList = component.get("v.shopSearchList");
        var shopSearch = component.get("v.shopSearch");
        unChooseShopAction.setParams({
            "currentShopId" : currentShop,
            "recordId": recordId,
            "shopSearchListJSON": JSON.stringify(shopSearchList),
            "shopListJSON": JSON.stringify(component.get("v.shopItemList")),
            "shopSearchMap": shopSearch
        });
        unChooseShopAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result.success) {
                    component.set("v.shopSearchList", result.shopSearchItemList);
                    component.set("v.shopItemList", result.shopItemList);
                    component.set("v.showWaiting", false);
                } else { 
                    this.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(unChooseShopAction);
    },

    onCheckGriddingHelper: function (component, event, currentValue, currentGridding) {
        console.log("进入onCheckGriddingHelper");
        var currentgridNewColumns = component.get("v.gridNewColumns");
        var checkGriddingAction = component.get("c.checkGriddingFunction");
        checkGriddingAction.setParams({
            "currentgridNewColumnsJSON": JSON.stringify(currentgridNewColumns),
            "currentValue": currentValue,
            "currentGridding": currentGridding,
            "recordId": component.get("v.recordId")
        });
        checkGriddingAction.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("state" + state);
            if (state === 'SUCCESS') {
                if (result.success) {
                    component.set("v.showWaiting", false);
                    component.set("v.gridNewColumns", result.gridNewColumns);
                } else {
                    this.showModal(component, event, 'Error', result.message, "error");
                    component.set("v.showWaiting", false);
                }
            } else {
                this.showModal(component, event, 'Error', response.getErrors(), "error");
                component.set("v.showWaiting", false);
            }
        });
        $A.enqueueAction(checkGriddingAction);
    }
})