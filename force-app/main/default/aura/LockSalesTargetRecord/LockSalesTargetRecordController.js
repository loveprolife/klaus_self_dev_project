({
	myAction : function(component, event, helper) {
		var result = {};
	    result.code = '1';
	    result.msg = 'Lock Record?';
	    component.set("v.result",result);
	},
	//确认锁定纪录
	LockRecord:function(component,event,helper){
        var action = component.get("c.lockRecord");
        var salesTargetTitleId = component.get("v.recordId");
        action.setParams({salesTargetTitleId : salesTargetTitleId});
		action.setCallback(this, function(data) {
		    var result = JSON.parse(data.getReturnValue());
		    console.log('result:'+ JSON.stringify(result)); 
		    component.set("v.isSubmitted",true); 
		    component.set("v.result",result); 
		    if(result.code != null && result.code == '0'){
                
		    }                                                                                                                                                                                                                                                                                                                                         
		});
		$A.enqueueAction(action);
	},
	assignCancel:function(component,event,helper){
		$A.get("e.force:closeQuickAction").fire();
	}
})