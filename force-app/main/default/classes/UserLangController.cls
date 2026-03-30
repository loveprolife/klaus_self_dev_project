/*
 * @Description:
 * @Author: weifucheng
 * @Date: 2026-01-20 09:59:56
 * @LastEditTime: 2026-01-26 14:32:56
 * @LastEditors: WFC
 * @Version: 1.0.0
 */
public with sharing class UserLangController{
    // ✅ 核心方法：获取用户【纯Language属性】 en/zh/fr
    @AuraEnabled(cacheable = true) // 开启缓存，提升性能，必须加
    public static Map<String, Object> getCurrentUserLanguage(){
        // ✅ 一行代码，返回纯语言，永不返回null/undefined
        String sfLanguage = UserInfo.getLanguage();
        User user = [SELECT Id, FederationIdentifier, Sales_Region__c
                     FROM user
                     WHERE Id = :UserInfo.getUserId()];
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('language', Language_Dictionary__c.getValues(sfLanguage) != null ? Language_Dictionary__c.getValues(sfLanguage).Value__c : 'en_GB');
        resultMap.put('user', user);
        return resultMap;
    }

}