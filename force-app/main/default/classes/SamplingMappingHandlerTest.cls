/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class SamplingMappingHandlerTest {
    static testMethod void testHandler() {
        Account acc = new Account();
        acc.Name = 'KS';
		INSERT acc;
        
		Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Shop_Level__c = 'A';
        sm.Level__c = 'A';
        INSERT sm;
        
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.RecordTypeId = Schema.getGlobalDescribe().get('Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        INSERT pro;
        
        Shop__c shop = new Shop__c();
        shop.Account__c = sm.Account__c;
        shop.Shop_Level__c =sm.Shop_Level__c;
        INSERT shop;
        
        Shop__c shop2 = new Shop__c();
        shop2.Account__c = sm.Account__c;
        shop2.Shop_Level__c ='B';
        INSERT shop2;
        
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        ss.Is_Added__c = '是';
        ss.Level__c = 'A';
        ss.Product__c = pro.Id;
        INSERT ss; 
        
		Sampling_Detail__c sd = new Sampling_Detail__c();
		sd.Sampling_Standard__c = ss.Id;
        sd.Shop__c = shop.Id;
        sd.Is_Add__c = '是';
        sd.ExternalID__c = acc.Id;
        INSERT sd;
        
        test.startTest();
        sm.Shop_Level__c = 'B';
        UPDATE sm;
		test.stopTest();
    }
    
   
}