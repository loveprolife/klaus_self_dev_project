({
	myAction : function(component, event, helper) {
		var result = {};
	    result.code = '1';
	    result.msg = $A.get("$Label.c.Quote_Confirm_Cost_Price_Alert");
	    component.set("v.result",result);  
	},
	//确认提交审批
	selectSubmit:function(component,event,helper){
        var action = component.get("c.confirmCostPrice");
        var quoteId = component.get("v.recordId");
        action.setParams({quoteId : quoteId});
		action.setCallback(this, function(data) {
		    var result = JSON.parse(data.getReturnValue());
		    console.log('result:'+ JSON.stringify(result));
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