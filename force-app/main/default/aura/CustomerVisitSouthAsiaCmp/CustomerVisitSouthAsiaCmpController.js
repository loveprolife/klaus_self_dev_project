({
	doInit : function(component, event, helper) {

		component.set("v.pdfUrl", "");
		component.set("v.ensureWindow", "yes");
		component.set("v.PDFframe", "no");
		component.set("v.closeFrame", "no");
		var CustomerVisitId = component.get("v.recordId");
		
		var visitDetail = component.get("c.getVisitDetail");
		visitDetail.setParams({
			CustomerVisitId:CustomerVisitId
		});
		visitDetail.setCallback(this, function (data){
			console.log('www--' + data.getReturnValue());
			component.set("v.visitDetail", data.getReturnValue());
		});
		$A.enqueueAction(visitDetail); 
		
	},
	admit : function(component, event, helper) {

		event.preventDefault();
        const fields = event.getParam('fields');
        fields.Customer_Visit_Lookup__c = component.get("v.recordId");
		component.find("editForm").submit(fields);

		component.set("v.ensureWindow", "no");
		component.set("v.PDFframe", "yes");
		component.set("v.closeFrame", "yse");

		var CustomerVisitId = component.get("v.recordId");
		component.set("v.pdfUrl", '/apex/CustomerVisitSouthAsiaReport?ID='+CustomerVisitId);
       
		$A.get("e.force:refreshView").fire();
	},
	cancel: function(component,event,helper){
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();		
	},
	close: function(component,event,helper){
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();			
	},
})