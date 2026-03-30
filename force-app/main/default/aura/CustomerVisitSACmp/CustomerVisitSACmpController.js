({
	doInit : function(component, event, helper) {
		component.set("v.pdfUrl", "/apex/CustomerVisitSAReport?ID="+component.get("v.recordId"));//v 是组件属性集的值提供程序
		var action = component.get("c.getCustomerVisit");//componnet.get("c.testAction"): 此逻辑代表获取后台apex controller中的 testAction方法，用于和后台交互操作，返回类型为Action对象变量，
		var CustomerVisitId = component.get("v.recordId");
		console.log('CustomerVisitId:'+CustomerVisitId);
        //匹配设备型号
        var sUserAgent = navigator.userAgent.toLowerCase();
        var bIsIpad = sUserAgent.match(/ipad/i) == "ipad";
        var bIsIphoneOs = sUserAgent.match(/iphone os/i) == "iphone os";
        var bIsMidp = sUserAgent.match(/midp/i) == "midp";
        var bIsUc7 = sUserAgent.match(/rv:1.2.3.4/i) == "rv:1.2.3.4";
        var bIsUc = sUserAgent.match(/ucweb/i) == "ucweb";
        var bIsAndroid = sUserAgent.match(/android/i) == "android";
        var bIsCE = sUserAgent.match(/windows ce/i) == "windows ce";
        var bIsWM = sUserAgent.match(/windows mobile/i) == "windows mobile";
        var isMobile = false;
        //移动适配
        if (bIsIpad || bIsIphoneOs || bIsMidp || bIsUc7 || bIsUc || bIsAndroid || bIsCE || bIsWM) {
            isMobile = true;
            alert($A.get("$Label.c.Common_Page_Only_Use_For_Browser"));
            $A.get("e.force:closeQuickAction").fire();
            return;
        }
		action.setParams({
			CustomerVisitId:CustomerVisitId
		});
		action.setCallback(this, function (data){
			var message = data.getReturnValue();
			console.log(message);
			var ensureWindow=document.querySelector('#ensureWindow');	
			var myframe = document.querySelector('#PDFframe');
			var closeFrame = document.querySelector('#closeFrame');
			if(message.Approval_Status__c =='Approved'){
				ensureWindow.className = 'hidden';
				myframe.className = 'visible';
				closeFrame.className = 'visible';
			}else{
				ensureWindow.className = 'visbile';
				myframe.className = 'hidden';
				closeFrame.className ='hidden';
			}	
		});
		$A.enqueueAction(action); 
	},
	admit : function(component, event, helper) {
		var ensureWindow=document.querySelector('#ensureWindow');	
		var myframe = document.querySelector('#PDFframe');
		var closeFrame = document.querySelector('#closeFrame');
		ensureWindow.className = 'hidden';
		myframe.className = 'visible';
		closeFrame.className = 'visible';
		
	},
	cancel: function(component,event,helper){
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();		
	},
	close: function(component,event,helper){
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();			
	}

})