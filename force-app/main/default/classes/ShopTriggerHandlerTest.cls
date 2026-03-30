/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class ShopTriggerHandlerTest {
    static testMethod void testHandler() {
        Account acc = new Account();
        acc.Name = 'KS';
        acc.SAP_Customer_Code__c = 'sapcode01';
		INSERT acc;
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.RecordTypeId = Schema.getGlobalDescribe().get('Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        INSERT pro;
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;
        Gridding__c gird2 = new Gridding__c();
        gird2.Name = 'test003';
        gird2.Gridding_Level__c = 'C';
        gird2.Gridding_Code__c  = 'J01-J001-J0001';
        gird2.Parent_Gridding__c = gird1.Id;
        INSERT gird2;
        Shop__c shop = new Shop__c();
        shop.Name = 'test001';
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird2.id;
        shop.Store_No_from_Account__c = '01';
        shop.City__c = '北京市';
        Shop__c shop2 = new Shop__c();
        shop2.Name = 'test002';
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Grid__c = gird2.id;
        shop2.Store_No_from_Account__c = '02';
        
        //Set<String> shopLevelSet2 = new Set<String>();
        ///shopLevelSet2.add(shop.Shop_Level__c);
        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = shop.Account__c;
        sm.Shop_Level__c = 'A;B';
        sm.Level__c = 'A';
        //sm.Shop_Level__c = 'A';
        INSERT sm;
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
        sd.Is_Add__c = '是';
        INSERT sd;
        test.startTest();
        INSERT shop;
        INSERT shop2;
        shop.Shop_Level__c = 'B';
        shop.Store_No_from_Account__c = '';
        shop.City__c = '青岛市';
        UPDATE shop;
        shop.City__c = '';
        UPDATE shop;
        shop2.Name = 'test001';
        update shop2;
		test.stopTest();
    }
}