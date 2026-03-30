({
	myAction : function(component, event, helper) {
		
	},
	//克隆数据
	Clone:function(component,event,helper){
        var action = component.get("c.cloneCreaditLimit");
        var creaditLimitId = component.get("v.recordId");
        console.log('ID:'+ creaditLimitId); 
        action.setParams({creaditLimitId : creaditLimitId});
		action.setCallback(this, function(data) {
		    var result = JSON.parse(data.getReturnValue());
		    console.log('result:'+ JSON.stringify(result)); 
		    component.set("v.isSubmitted",true); 
		    component.set("v.result",result); 
		    if(result.code != null && result.code == '0'){
                var navEvt = $A.get("e.force:navigateToSObject");
			    navEvt.setParams({"recordId": result.msg});
			    navEvt.fire();
		    }                                                                                                                                                                                                                                                                                                                                         
		});
		$A.enqueueAction(action);
	},
	assignCancel:function(component,event,helper){
		$A.get("e.force:closeQuickAction").fire();
	}
})