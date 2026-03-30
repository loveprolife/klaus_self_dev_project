/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class SamplingStandardHandlerTest {
    static testMethod void testHandler01() {
        Account acc = new Account();
        acc.Name = 'KS';
		INSERT acc;
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.RecordTypeId = Schema.getGlobalDescribe().get('Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        INSERT pro;
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        INSERT shop;
        Set<String> shopLevelSet2 = new Set<String>();
        shopLevelSet2.add(shop.Shop_Level__c);
        Sampling_Mapping__c smForA = new Sampling_Mapping__c();
        smForA.Account__c = acc.Id;
        smForA.Shop_Level__c = shop.Shop_Level__c;
        smForA.Level__c = 'A';
        INSERT smForA;
        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Shop_Level__c = shop.Shop_Level__c;
        sm.Level__c = 'B';
        //sm.Shop_Level__c = 'A';
        INSERT sm;
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = false;
        ss.Is_Added__c = '是';
        ss.Level__c = 'B';
        ss.Product__c = pro.Id;
		INSERT ss;         
		Sampling_Detail__c sd = new Sampling_Detail__c();
		sd.Sampling_Standard__c = ss.Id;
        sd.Is_Add__c = '是';
        INSERT sd;
        test.startTest();
        
        ss.Level__c = 'B';
        ss.Is_Added__c = '否';
        ss.Is_Add_ByReport__c = false;
        UPDATE ss;
        ss.Level__c = 'A';
        ss.Is_Added__c = '是';
        ss.Is_Add_ByReport__c = false;
        UPDATE ss;
        ss.Level__c = 'B';
        ss.Is_Added__c = '是';
        ss.Is_Add_ByReport__c = false;
        UPDATE ss;
		test.stopTest();
    }
     
}