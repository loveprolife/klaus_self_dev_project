/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 25-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
trigger ProductSpivTrigger on ProductSpiv__c (before insert, before update, before delete, after insert, after update) {
	new ProductSpivTriggerHandler().run();
}