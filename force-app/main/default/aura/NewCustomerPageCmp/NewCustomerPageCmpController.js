/*
 * @Author: WFC
 * @Date: 2023-11-22 15:59:36
 * @LastEditors: WFC
 * @LastEditTime: 2024-11-20 14:56:51
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\aura\NewCustomerPageCmp\NewCustomerPageCmpController.js
 */
({
    initCMP: function(component,event,helper){
        // var pathUrl = window.location.href;
        // let obj = {}
        // let arr = pathUrl.split('?')
        // pathUrl = arr[1]
        // let array = pathUrl.split('&')
        // for (let i = 0; i < array.length; i++) {
        //     let arr2 = array[i]
        //     let arr3 = arr2.split('=')
        //     obj[arr3[0]] = arr3[1]
        // }
        // console.log('recordTypeId: ' + obj.recordTypeId);
        // component.set('v.recordTypeId', obj.recordTypeId);
        component.set('v.recordTypeId', '0120o0000017UVuAAM');
	},
    refreshView : function(component,event,helper) {
        console.log('click cancel...refreshView' );
        $A.get('e.force:refreshView').fire();
    },
    closeModal : function(component,event,helper) {
        console.log('click cancel...closeModal');
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
})