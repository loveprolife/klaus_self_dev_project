({
    myAction : function(component, event, helper) {
        var result = {};
        result.code = '1';
        result.msg = $A.get("$Label.c.Customer_Visit_Clone_Comfirm");
        component.set("v.result",result);  
    },
    //确认克隆
    selectSubmit:function(component,event,helper){
        var action = component.get("c.copyCustomerVisit");
        var cvId = component.get("v.recordId");
        action.setParams({cvId : cvId});
        action.setCallback(this, function(data) {
            var result = JSON.parse(data.getReturnValue());
            console.log('result:'+ JSON.stringify(result)); 
            component.set("v.isSubmitted",true); 
            if(result.code != null && result.code == '0'){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({"recordId": result.msg});
                navEvt.fire();
            }else{
                component.set("v.result",result);
            }                                                                                                                                                                                                                                                                                                                                             
        });
        $A.enqueueAction(action);
    },
    assignCancel:function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})