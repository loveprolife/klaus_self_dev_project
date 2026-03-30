({
    init: function (component, event, helper) {
        var pageLabelList = $A.get("$Label.c.Change_Sales_All_Page_Label").split('&');
        var salesList1 = [];
        salesList1.push({"attributes": {"type": "Customer_Product_Line__c"},'Key_Sales__c' : ''});
        component.set("v.salesList1",salesList1);
        var salesList2 = [];
        salesList2.push({"attributes": {"type": "Customer_Product_Line__c"},'Key_Sales__c' : ''}); 
        component.set("v.salesList2",salesList2);
        component.set("v.pageLabelList",pageLabelList);


    },
    changeSales: function (component, event, helper) {
        var oldUserId = component.get('v.salesList1')[0].Key_Sales__c.substring(0,15);
        var targetUserId = component.get('v.salesList2')[0].Key_Sales__c.substring(0,15);
        console.log('oldUserId: ' + oldUserId);
        console.log('targetUserId: ' + targetUserId);
        
        var action = component.get("c.changeTwoSales");
        if(oldUserId == '' || targetUserId == ''){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": "Sales can not be empty!"
                });
                toastEvent.fire();
            return ;
        }
        if(oldUserId == targetUserId){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": "Two sales can not be same!"
                });
                toastEvent.fire();
            return ;
        }
        
        action.setParams({
           oldUserId : oldUserId,
           targetUserId : targetUserId
        });
        action.setCallback(this, function(data) {
            var result = data.getReturnValue();
            setTimeout(function() {
           	if(result == 'success!'){
                var toastEvent2 = $A.get("e.force:showToast");
                toastEvent2.setParams({
                    "type": "success",
                    "title": "Success",
                    "message": "The records have been updated successfully!"
                });
                toastEvent2.fire();
                return ;
            }else{
                var toastEvent3 = $A.get("e.force:showToast");
                toastEvent3.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": result
                });
                toastEvent3.fire();
                return ;
            }          
        }, 500);
        });
        $A.enqueueAction(action);

    },
    change1:function(component,event,helper){
    	var index = event.getSource().get("v.id");
        component.get('v.salesList1')[index].Key_Sales__c = event.getSource().get('v.value');
    },
    change2:function(component,event,helper){
    	var index = event.getSource().get("v.id");
        component.get('v.salesList2')[index].Key_Sales__c = event.getSource().get('v.value');
    }
})