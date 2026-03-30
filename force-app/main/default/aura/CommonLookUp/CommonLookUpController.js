({
    fetchResultHandler : function(component, event, helper) {
		var keyWord = component.get("v.searchKeyWord");
        var resultListDiv = component.find("searchRes");
        if( keyWord.length >= 2){
            $A.util.addClass(resultListDiv, 'slds-is-open');
            $A.util.removeClass(resultListDiv, 'slds-is-close');
            helper.searchHelper(component,event,keyWord);
        }
        else{  
            component.set("v.searchObjList", null ); 
            $A.util.addClass(resultListDiv, 'slds-is-close');
            $A.util.removeClass(resultListDiv, 'slds-is-open');
        }
	},
	hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },

    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },

    recordSelectedHandler : function(component, event, helper) {
        var selectedRecord = event.getParam('selectedRecord');
        var singleOrMultiple = component.get('v.singleOrMultiple');
        if(singleOrMultiple) {
            component.set('v.selectedRecord',selectedRecord);
        } else {
            var selectedRecordList = component.get('v.selectedRecordList');
            selectedRecordList.push(selectedRecord);
            component.set('v.selectedRecordList',selectedRecordList);
        }
        var pillDiv = component.find("lookup-pill");
        $A.util.addClass(pillDiv, 'slds-show');
        $A.util.removeClass(pillDiv, 'slds-hide');

        var resultListDiv = component.find("searchRes");
        $A.util.addClass(resultListDiv, 'slds-is-close');
        $A.util.removeClass(resultListDiv, 'slds-is-open');

        if(singleOrMultiple) {
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        }
        component.set('v.searchKeyWord', null);
    },
    clearSelectedHandlerWhenSingle : function(component, event,helper) {
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
      
        component.set("v.searchKeyWord",null);
        component.set("v.searchObjList", null );
    },
    clearSelectedHandlerWhenMulple : function(component,event,helper) {
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.selectedRecordList"); 
        console.log(JSON.stringify(AllPillsList));
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].objId == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.selectedRecordList", AllPillsList);
            }  
        }
        component.set("v.searchKeyWord",null);
        component.set("v.searchObjList", null );      
    },
    openView : function(component,event,helper) {
        // var selectedPillId = event.getSource().get("v.name");
        // window.open("/lightning/r/" + selectedPillId + "/view","_blank");
        // var compEvent = component.getEvent("CommonMethodEvt");
        // compEvent.fire();
    },
    addUser : function(component,event,helper) {
        // var createAcountContactEvent = $A.get("e.force:createRecord");
		// createAcountContactEvent.setParams({
		//     "entityApiName": "Send_Email_User__c",
		//     "defaultFieldValues": {
		        
		//     }
		// });
		// createAcountContactEvent.fire();
        component.set("v.isOpen",true);
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    handleSubmit : function(component,event,helper) {
        component.find("editForm").submit();
    },
    handleSuccess : function(component,event,helper) {
        var resultsToast = $A.get("e.force:showToast");
        var record = event.getParam("response");
        var apiName = record.apiName;
        var userRecordId = record.id;
        console.log('apiName: ' + apiName);
        console.log('userRecordId: ' + userRecordId);
        // 添加用户后自动添加在收件人或者抄送人里
        var action = component.get("c.searchUserById");
        action.setParams({
            userRecordId : userRecordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resValue = response.getReturnValue();
                var selectedRecordList = component.get('v.selectedRecordList');
                selectedRecordList.push(resValue);
                component.set("v.selectedRecordList", selectedRecordList);
            }
        });
        $A.enqueueAction(action);

        if(resultsToast) {
            resultsToast.setParams({
                "type": "success",
                "title": "Success",
                "message": "Save successfully!"
            });
            resultsToast.fire();
        }
        component.set("v.isOpen", false);
        component.set("v.searchObjList", null );
        var resultListDiv = component.find("searchRes"); 
        $A.util.addClass(resultListDiv, 'slds-is-close');
        $A.util.removeClass(resultListDiv, 'slds-is-open');
    },
    handleError : function(component,event,helper) {
        var resultsToast = $A.get("e.force:showToast");
        if(resultsToast) {
            resultsToast.setParams({
                "type": "error",
                "title": "Error",
                "message": "Save failure!"
            });
            resultsToast.fire();
        }
        component.set("v.searchObjList", null );
        var resultListDiv = component.find("searchRes"); 
        $A.util.addClass(resultListDiv, 'slds-is-close');
        $A.util.removeClass(resultListDiv, 'slds-is-open');
    },
})