/*
 * @Author: WFC
 * @Date: 2023-02-07 18:07:36
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-02 13:04:28
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\aura\CommonLookUp\CommonLookUpHelper.js
 */
({
    searchHelper : function(component,event,getInputkeyWord) {
        var action = component.get("c.search");
        var retrieveWrapper = {};
        retrieveWrapper.retrieveKeyWord = getInputkeyWord;
        retrieveWrapper.searchGroup = component.get('v.searchGroup');
        retrieveWrapper.objName2FieldMap = component.get('v.searchFieldMapping2Object');
        retrieveWrapper.objName2QueryConditionMap = component.get('v.searchCondition');
        action.setParams({
            wrapper : retrieveWrapper
        });
   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resValue = response.getReturnValue();
                if (resValue.length == 0) {
                    component.set("v.message", 'No Result Found.');
                } else {
                    component.set("v.message", 'Search Result As Follows.');
                }
                
                component.set("v.searchObjList", resValue);
            }
        });
        $A.enqueueAction(action);
	}
})