/*
 * @Author: WFC
 * @Date: 2025-04-24 14:42:00
 * @LastEditors: TJP
 * @LastEditTime: 2025-08-14 13:59:16
 * @Description: 
 * @FilePath: \HiTest20250422\force-app\main\default\aura\NewStorePageCmp\NewStorePageCmpController.js
 */
({
    initCMP: function(component,event,helper){
        // 校验是否是上线国家
        let isProfileName = true;
        //原逻辑手动配置字段来进行页面展示
        //let profileNameList = $A.get("$Label.c.New_Store_Profile_Name").split(',');
        let action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
            let user = response.getReturnValue();
            // profileNameList.forEach(item => {
            //     if(user.Profile.Name.indexOf(item) != -1){
            //         isProfileName = true;
            //     }
            // });
            component.set('v.isProfileName', isProfileName);

            // 解析地址信息
            var pathUrl = window.location.href;
            let obj = {}
            let arr = pathUrl.split('?')
            if(arr.length > 1){
                pathUrl = arr[1]
                let array = pathUrl.split('&')
                if(array.length > 0){
                    for (let i = 0; i < array.length; i++) {
                        let arr2 = array[i]
                        let arr3 = arr2.split('=')
                        obj[arr3[0]] = arr3[1]
                    }
                    console.log('recordTypeId: ' + obj.recordTypeId);
                    component.set('v.recordTypeId', obj.recordTypeId);
                }
                let startUrl = arr[0];
                if(startUrl.indexOf('new') !== -1 || startUrl.indexOf('edit') !== -1){
                    component.set('v.isNew', true);
                }else {
                    component.set('v.isNew', false);
                }
            }
        });
        $A.enqueueAction(action);
        
        
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