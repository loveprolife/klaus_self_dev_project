({
	myAction : function(component, event, helper) {

        var result = {};
	    result.code = '1';
        result.msg = $A.get("$Label.c.Undo_Changes_Info");
	    //result.msg = $A.get("$Label.c.Customer_Get_Credit_Limit_Title") + '?';
	    component.set("v.result",result);  
	},
    selectSubmit:function(component,event,helper){
		component.set('v.showSpinner', true);

        var recordId = component.get("v.recordId");
        var action = component.get("c.initData");
        var jsonData;
        action.setParams({recordIdStr : recordId});
        action.setCallback(this, function(data) {
            var result = JSON.parse(data.getReturnValue());
            console.log(result);

            component.set('v.showSpinner', false);
		    component.set("v.result",result); 
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