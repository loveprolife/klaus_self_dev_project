/*
 * @Author: WFC
 * @Date: 2023-02-07 16:35:19
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-07 17:16:51
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\aura\CheckUser\CheckUserController.js
 */
({
    myAction : function(component, event, helper) {

    },
    initCMP: function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.searchById");
        action.setParams({
            recordId : recordId
        });
   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resValue = response.getReturnValue().addressSearchResultWrapper;
                if (resValue != null) {
                    var selectedRecordList = component.get('v.selectedRecordList');
                    resValue.forEach(element => {
                        selectedRecordList.push(element);
                    });
                    component.set('v.selectedRecordList',selectedRecordList);
                }
                var resValueCC = response.getReturnValue().ccSearchResultWrapper;
                if (resValueCC != null) {
                    var selectedRecordListCC = component.get('v.selectedRecordListCC');
                    resValueCC.forEach(element => {
                        selectedRecordListCC.push(element);
                    });
                    component.set('v.selectedRecordListCC',selectedRecordListCC);
                }
                component.set('v.isCanSend',response.getReturnValue().isCanSend);
            }
        });
        $A.enqueueAction(action);
        
	},
    getMessage : function(component,event,helper){
        for(var i=0;i< component.get('v.selectedRecordList').length;i++) {
            var selectedRecord = component.get('v.selectedRecordList')[i];
            console.log(selectedRecord.objId);
            console.log(selectedRecord.objName);
            console.log(selectedRecord.objValue);
            console.log(selectedRecord.objLabel);
        }
    },
    send : function(component,event,helper){
        console.log('send');
        var ids = '';
        var emailAddress = '';
        var usernameAddress = '';

        var ccIds = '';
        var ccEmailAddress = '';
        var ccUsernameAddress = '';
        
        for(var i=0;i< component.get('v.selectedRecordList').length;i++) {
            var selectedRecord = component.get('v.selectedRecordList')[i];
            console.log('selectedRecord.objId:' + selectedRecord.objId);
            console.log('selectedRecord.objName:' +selectedRecord.objName);
            console.log('selectedRecord.objValue:' +selectedRecord.objValue);
            console.log('selectedRecord.objLabel:' +selectedRecord.objLabel);
            console.log('selectedRecord.objEmail:' +selectedRecord.objEmail);
            ids += selectedRecord.objId + ',';
            emailAddress += selectedRecord.objEmail + ',';
            usernameAddress += selectedRecord.objValue + ',';
        }
        for(var i=0;i< component.get('v.selectedRecordListCC').length;i++) {
            var selectedRecord = component.get('v.selectedRecordListCC')[i];
            console.log('selectedRecord.objId:' + selectedRecord.objId);
            console.log('selectedRecord.objName:' +selectedRecord.objName);
            console.log('selectedRecord.objValue:' +selectedRecord.objValue);
            console.log('selectedRecord.objLabel:' +selectedRecord.objLabel);
            console.log('selectedRecord.objEmail:' +selectedRecord.objEmail);
            ccIds += selectedRecord.objId + ',';
            ccEmailAddress += selectedRecord.objEmail + ',';
            ccUsernameAddress += selectedRecord.objValue + ',';
        }
        
        if(ids == ''){
            var resultsToast = $A.get("e.force:showToast");
            if(resultsToast) {
                resultsToast.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": "收件人不能为空！"
                });
                resultsToast.fire();
            }
            return;
        }

        ids = ids.substring(0, ids.length - 1);
        emailAddress = emailAddress.substring(0, emailAddress.length - 1);
        usernameAddress = usernameAddress.substring(0, usernameAddress.length - 1);

        ccIds = ccIds.substring(0, ccIds.length - 1);
        ccEmailAddress = ccEmailAddress.substring(0, ccEmailAddress.length - 1);
        ccUsernameAddress = ccUsernameAddress.substring(0, ccUsernameAddress.length - 1);

        var recordId = component.get("v.recordId");
        console.log('recordId:' + recordId);
        var action = component.get("c.sendEmail");
        var sendEmailField = {};
        sendEmailField.recordId = recordId;
        sendEmailField.ids = ids;
        sendEmailField.emailAddress = emailAddress;
        sendEmailField.usernameAddress = usernameAddress;
        sendEmailField.ccIds = ccIds;
        sendEmailField.ccEmailAddress = ccEmailAddress;
        sendEmailField.ccUsernameAddress = ccUsernameAddress;
        action.setParams({
            sendEmailField : sendEmailField,
        });
   
        action.setCallback(this, function(response) {
            var result = JSON.parse(response.getReturnValue());
            console.log('result:'+ JSON.stringify(result)); 
            if(result.code != null && result.code == '0'){
                var resultsToast = $A.get("e.force:showToast");
                if(resultsToast) {
                    resultsToast.setParams({
                        "type": "success",
                        "title": "Success",
                        "message": result.msg
                    });
                    resultsToast.fire();
                }
            }else{
                var resultsToast = $A.get("e.force:showToast");
                if(resultsToast) {
                   resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": result.msg
                   });
                   resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    save : function(component,event,helper){
        console.log('save');
        var ids = '';
        var emailAddress = '';
        var usernameAddress = '';

        var ccIds = '';
        var ccEmailAddress = '';
        var ccUsernameAddress = '';
        
        for(var i=0;i< component.get('v.selectedRecordList').length;i++) {
            var selectedRecord = component.get('v.selectedRecordList')[i];
            console.log('selectedRecord.objId:' + selectedRecord.objId);
            console.log('selectedRecord.objName:' +selectedRecord.objName);
            console.log('selectedRecord.objValue:' +selectedRecord.objValue);
            console.log('selectedRecord.objLabel:' +selectedRecord.objLabel);
            console.log('selectedRecord.objEmail:' +selectedRecord.objEmail);
            ids += selectedRecord.objId + ',';
            emailAddress += selectedRecord.objEmail + ',';
            usernameAddress += selectedRecord.objValue + ',';
        }
        for(var i=0;i< component.get('v.selectedRecordListCC').length;i++) {
            var selectedRecord = component.get('v.selectedRecordListCC')[i];
            console.log('selectedRecord.objId:' + selectedRecord.objId);
            console.log('selectedRecord.objName:' +selectedRecord.objName);
            console.log('selectedRecord.objValue:' +selectedRecord.objValue);
            console.log('selectedRecord.objLabel:' +selectedRecord.objLabel);
            console.log('selectedRecord.objEmail:' +selectedRecord.objEmail);
            ccIds += selectedRecord.objId + ',';
            ccEmailAddress += selectedRecord.objEmail + ',';
            ccUsernameAddress += selectedRecord.objValue + ',';
        }

        ids = ids.substring(0, ids.length - 1);
        emailAddress = emailAddress.substring(0, emailAddress.length - 1);
        usernameAddress = usernameAddress.substring(0, usernameAddress.length - 1);

        ccIds = ccIds.substring(0, ccIds.length - 1);
        ccEmailAddress = ccEmailAddress.substring(0, ccEmailAddress.length - 1);
        ccUsernameAddress = ccUsernameAddress.substring(0, ccUsernameAddress.length - 1);

        var recordId = component.get("v.recordId");
        console.log('recordId:' + recordId);
        var action = component.get("c.saveAddress");
        var sendEmailField = {};
        sendEmailField.recordId = recordId;
        sendEmailField.ids = ids;
        sendEmailField.emailAddress = emailAddress;
        sendEmailField.usernameAddress = usernameAddress;
        sendEmailField.ccIds = ccIds;
        sendEmailField.ccEmailAddress = ccEmailAddress;
        sendEmailField.ccUsernameAddress = ccUsernameAddress;
        action.setParams({
            sendEmailField : sendEmailField,
        });
   
        action.setCallback(this, function(response) {
            var result = JSON.parse(response.getReturnValue());
            console.log('result:'+ JSON.stringify(result)); 
            if(result.code != null && result.code == '0'){
                var resultsToast = $A.get("e.force:showToast");
                if(resultsToast) {
                    resultsToast.setParams({
                        "type": "success",
                        "title": "Success",
                        "message": result.msg
                    });
                    resultsToast.fire();
                }
            }else{
                var resultsToast = $A.get("e.force:showToast");
                if(resultsToast) {
                   resultsToast.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": result.msg
                   });
                   resultsToast.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

})