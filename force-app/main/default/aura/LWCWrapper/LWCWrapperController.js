({
    doInit : function(cmp) {
        let pageReference = cmp.get("v.pageReference");
        let para = {
            "aura:id": "findableAuraId",
            "onrefresh" :cmp.getReference("c.onRefresh")
        };
        cmp.set('v.url', window.location.href);
        var toastEvent = $A.get("e.force:showToast");
        if (!(pageReference && pageReference.state)) {
            toastEvent.setParams({
                "message" : 'lwcName is blank',
                "type" : "error"
            });
            toastEvent.fire();
            return;
        }
        
        for (let key in pageReference.state) {
            if (key.indexOf('c__') == 0) {
                para[key.substring(3)] = pageReference.state[key];
            }
            para[key] = pageReference.state[key];
        }
        
        // para["browser"] = $A.get("$Browser");
        // let aa = $A.get("$Label.c.WeekResearch_UNACTIVE");
        window.dollarA = $A;
        if (para['lwcName']) {
            $A.createComponent(
                "c:" + para['lwcName'],
                para,
                (newButton, status, errorMessage) => {
                    //Add the new button to the body array
                    if (status === "SUCCESS") {
                        var body = cmp.get("v.body");
                        body.push(newButton);
                        cmp.set("v.body", body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        
                        toastEvent.setParams({
                            "message" : 'lwcName create is error',
                            "type" : "error"
                        });
                        toastEvent.fire();
                        // Show error message
                    }
                }
            );
        } else {
            this.showError('lwcName is blank')
        }
    },

    onRender : function(cmp, event) {
        console.log("lwcWrapper onRender");
        if (cmp.get('v.url') && cmp.get('v.url') != window.location.href) {
            // window.location.reload();
            $A.get('e.force:refreshView').fire();
        }
    },

    onRefresh:function(cmp, event) {
        console.log("lwcWrapper onRefresh");
        $A.get('e.force:refreshView').fire();
    }
})