({
    showModal: function(cmp, evt, title, message, msgType) {
        var toast = $A.get("e.force:showToast");
        toast.setParams({ 
            "title" : title,
            "message" : message,
            "type" : msgType,
            "mode" : "dismissible",
            "duration" : "8000"
        }); 
        toast.fire();
    }
})