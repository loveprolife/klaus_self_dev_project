/*
 * @Author: LZX
 * @Date: 2024-01-31 17:58:47
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2024-02-19 11:08:11
 * @FilePath: \hisenseall-231026\force-app\main\default\aura\ChannelUploadCMP\ChannelUploadCMPController.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
({
    refreshView : function(component,event,helper) {
        component.set('v.isOpen',true);
        console.log('click cancel...refreshView' );
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        // component.set("v.isOpen", false);
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Promoter_Cost__c',
                actionName: 'list'
            },
        };
        component.set("v.pageReference", pageReference);
        navService.navigate(pageReference);
        // console.log('click cancel...closeModal');
        // $A.get("e.force:closeQuickAction").fire();
        // $A.get('e.force:refreshView').fire();
    },
    submit: function(component, event, helper) {
        var year = component.find('InputSelectSingleYear');
        var month = component.find('InputSelectSingleMonth');
        var date = year.get('v.value') + '-' + month.get('v.value');
        component.set('v.dateYearMonth',date);
        component.set('v.isOpen',false);
        console.log('submit');
        // console.log(component.get('v.date'));
        console.log(component.get('v.dateYearMonth'));
    },
    myAction : function(component, event, helper) {

    },
    init : function(component, event, helper) {
        component.set('v.isOpen',true);
        // var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set('v.objectLoad', 'Promoter Cost');
        console.log('wwwww=====' + window.location.pathname);
        console.log(window.name);
	},
})