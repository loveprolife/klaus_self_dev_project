({
    selectRecord : function(component, event, helper) {
    	var selectedRecord = component.get("v.selectedRecord");
        var compEvent = component.getEvent("CommonRecordSelectedEvt");
        for(var i=0;i< component.get('v.selectedRecordList').length;i++) {
            var selectedRecordOld = component.get('v.selectedRecordList')[i];
            if(selectedRecordOld.objId == selectedRecord.objId){
                var resultsToast = $A.get("e.force:showToast");
                if(resultsToast) {
                   resultsToast.setParams({
                        "type": "info",
                        "title": "Info",
                        "message": "已选择!"
                   });
                   resultsToast.fire();
               }
                return;
            }
        }
        compEvent.setParams({"selectedRecord" : selectedRecord});
        compEvent.fire();
    }
})