({
	myAction : function(component, event, helper) {
		var result = {};
	    result.code = '1';
	    result.msg = $A.get("$Label.c.Customer_Sync_To_SAP_Confirm");
	    component.set("v.result",result);  
	},
	//确认同步客户到SAP
	selectSubmit:function(component,event,helper){
		component.set('v.showSpinner', true);
        var action = component.get("c.syncCustomerToSAP");
        var customerId = component.get("v.recordId");
        action.setParams({customerId : customerId});
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