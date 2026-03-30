/*
 * @Author: WFC
 * @Date: 2025-03-05 09:12:05
 * @LastEditors: WFC
 * @LastEditTime: 2025-10-22 09:47:43
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\aura\EventReceiptPDFCmp\EventReceiptPDFCmpController.js
 */
({
	doInit : function(component, event, helper) {
		component.set("v.pdfUrl", "/apex/EventReceiptPDFPage?ID="+component.get("v.recordId"));//v 是组件属性集的值提供程序
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
        //移动适配
        if (bIsIpad || bIsIphoneOs || bIsMidp || bIsUc7 || bIsUc || bIsAndroid || bIsCE || bIsWM) {
			component.set("v.isMobile",true);
			// alert($A.get("$Label.c.Common_Page_Only_Use_For_Browser"));
			
			var generatePDF = component.get("c.generatePDF");
			generatePDF.setParams({
				recordId : component.get("v.recordId")
			});
			generatePDF.setCallback(this, function(response) {
				var state = response.getState();
				var result = response.getReturnValue();
				if(state === "SUCCESS"){
					// 生成dpf文件，并跳转
					var navService = component.find("navService");
					// Sets the route to /lightning/o/Account/home
					var pageReference = {
						type: 'standard__recordPage',
						attributes: {
							recordId: result.ContentDocumentId,
							actionName: 'view'
						},
					};
					// event.preventDefault();
					navService.navigate(pageReference);
				}else {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "",
						"message": "Failed to generate PDF",
						"type": "error" // 可选值：success, error, warning, info
					});
					toastEvent.fire();
				}
			});
			$A.enqueueAction(generatePDF);
        }else {
			component.set("v.isMobile",false);
		}
	},
	admit : function(component, event, helper) {
		if(component.get("v.isMobile")){
			// const pdfUrl = "/apex/EventReceiptPDFPage?ID="+component.get("v.recordId");
			// window.open(pdfUrl, '_blank');

			var generatePDF = component.get("c.generatePDF");
			generatePDF.setParams({
				recordId : component.get("v.recordId")
			});
			generatePDF.setCallback(this, function(response) {
				var state = response.getState();
				var result = response.getReturnValue();
				if(state === "SUCCESS"){
					// 生成dpf文件，并跳转
					var navService = component.find("navService");
					// Sets the route to /lightning/o/Account/home
					var pageReference = {
						type: 'standard__recordPage',
						attributes: {
							recordId: result.ContentDocumentId,
							actionName: 'view'
						},
					};
					event.preventDefault();
					navService.navigate(pageReference);
				}else {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "",
						"message": "Failed to generate PDF",
						"type": "error" // 可选值：success, error, warning, info
					});
					toastEvent.fire();
				}
			});
			$A.enqueueAction(generatePDF);
		}else {
			var ensureWindow=document.querySelector('#ensureWindow');	
			var myframe = document.querySelector('#PDFframe');
			var closeFrame = document.querySelector('#closeFrame');
			ensureWindow.className = 'hidden';
			myframe.className = 'visible';
			closeFrame.className = 'visible';
		}
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