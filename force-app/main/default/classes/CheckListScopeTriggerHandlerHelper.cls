/*
 * @Author: Su,Tiger Shanhu
 * @Date: 2023-07-03 10:32:09
 * @LastEditors: Su,Tiger Shanhu
 * @LastEditTime: 2023-07-05 16:25:19
 * @Description: CheckListScopeTriggerHandlerHelper
 */
public without sharing class CheckListScopeTriggerHandlerHelper {

    public static void updateCheckItemIdInfo(List<CheckListScope__c> oldList, List<CheckListScope__c> newList){
        Map<Id, CheckListScope__c> oldMap = new Map<Id, CheckListScope__c>();
        Boolean isUpdate = false;
        if(oldList != null) {
            isUpdate = true;
            oldMap = new Map<Id, CheckListScope__c>(oldList);
        }
        System.debug('CheckListScopeTriggerHandlerHelper —> updateCheckItemIdInfo —> isUpdate：' + isUpdate);
        for(CheckListScope__c item : newList) {
            if(isUpdate) {
                if(oldMap.get(item.Id).CheckItem__c != item.CheckItem__c) {
                    item.CheckItemId__c = item.CheckItem__c;
                }
                if(oldMap.get(item.Id).Customer__c != item.Customer__c) {
                    item.CustomerId__c = item.Customer__c;
                }
            } else {
                item.CheckItemId__c = item.CheckItem__c;
                item.CustomerId__c = item.Customer__c;
            }
        }
    }

    public static void updateCheckItem(List<CheckListScope__c> newList) {
        List<String> checkItemIdList = new LisqContainer(newList).WhereOne('Active__c','=',true).SelectField('CheckItem__c').ToS();
        System.debug('checkItemIdList---' + JSON.serialize(checkItemIdList));
        List<CheckItem__c> updateList = new List<CheckItem__c>();
        for (CheckItem__c checkItem : [select Id, BeingUsed__c from CheckItem__c Where Id=:checkItemIdList ]) {
            if (!checkItem.BeingUsed__c ) {
                checkItem.BeingUsed__c = true;
                updateList.add(checkItem);
            }
        }
        if (updateList.size()>0) {
            update updateList;
        }
    }
}