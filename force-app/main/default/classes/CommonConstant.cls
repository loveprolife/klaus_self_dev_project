/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public without sharing class CommonConstant {
    public static final String productJapanModelReocrdTypeId = Schema.getGlobalDescribe().get('Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
    
}