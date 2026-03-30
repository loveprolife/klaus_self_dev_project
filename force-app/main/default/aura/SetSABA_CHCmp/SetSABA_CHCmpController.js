({
    myAction : function(component, event, helper) {
        var result = {};
        result.code = '1';
        result.msg = 'Calculate the actual sales volume ?';
        component.set("v.result",result);  
    },
    //从RR获取客户信用额度
    selectSubmit:function(component,event,helper){
        component.set('v.showSpinner', true);
        var action = component.get("c.runBatch");
        var recordId = component.get("v.recordId");
        action.setParams({recordId : recordId});
        action.setCallback(this, function(data) {
            var result = JSON.parse(data.getReturnValue());
            console.log('result:'+ JSON.stringify(result));
            component.set('v.showSpinner', false);
            component.set("v.result",result); 
            component.set("v.isSubmitted",true); 
            if(result.code != null && result.code == '0'){
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }	                                                                                                                                                                                                                                                                                                                                         
        });
        $A.enqueueAction(action);
    },
    assignCancel:function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})