@istest
public with sharing class PromoterDailyReportHandler2Test {
    static String giftProduct =  Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
    static String japanProduct = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
    @TestSetup
    static void makeData(){
        
    }
    @IsTest
    static void testCreateInventoryItem(){

        List<Product__c> poList = new List<Product__c>();
        Product__c productTest = new Product__c();
        productTest.Name = 'NTC-22E';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'NTC-22E-jp';
        productTest.RecordTypeId = japanProduct;

        poList.add(productTest);
        Product__c productGifTest = new Product__c();
        productGifTest.Name = 'Gift-22E';
        productGifTest.CurrencyIsoCode = 'USD';
        productGifTest.Product_External_Id__c = 'gift-22E-jp';
        productGifTest.RecordTypeId = giftProduct;
        poList.add(productGifTest);
        insert polist;
        
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='test777@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing777', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test777@noemail.com');
        INSERT user1;
        
        User user2 = new User(alias = '巡店员', email='testSA@noemail.com',
        emailencodingkey='UTF-8', lastname='TestSA777', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testSA@noemail.com');
        INSERT user2;
        
        Account customerTest = new Account();
        customerTest.Name = '测试客户1';
        Insert customerTest;
        
        Gridding__c testGrid = new Gridding__c();
        testGrid.Name = '测试网格';
        testGrid.Gridding_Level__c = 'A';
        testGrid.OwnerId = user1.id;
        Insert testGrid;
        
        Shop__c shopTest = new Shop__c();
        shopTest.Name = '测试门店1';
        shopTest.City__c = '重庆';
        shopTest.Account__c = customerTest.id;
        shopTest.Shop_Level__c = 'A';
        shopTest.GiftGrid__c = testGrid.id;
        Insert shopTest;
        
        Promoter_Daily_Report__c pd = new Promoter_Daily_Report__c();
        pd.Status__c = 'New';
        pd.Shop__c = shopTest.Id;
        pd.IsNew__c = true;
        pd.IsChange__c = false;
        pd.IsPerformance__c = true;
        insert pd;

		Promoter_Daily_Report__c pd2 = new Promoter_Daily_Report__c();
        pd2.Status__c = 'Submitted';
        pd2.Shop__c = shopTest.Id;
        pd2.Report_Date__c = Date.newInstance(2023,12,26);
        pd2.IsNew__c = true;
        pd2.IsChange__c = false;
        pd2.SARegionalManager__c = user2.id;
        pd2.IsPerformance__c = true;
        
        Retail_Number__c retailNumber = new Retail_Number__c();
        retailNumber.CurrencyIsoCode = 'USD';
        retailNumber.HasGift__c = true;
        retailNumber.Gift__c = productGifTest.id;
        retailNumber.Product__c = productTest.id;
        retailNumber.Shop__c = shopTest.id;
        retailNumber.Number__c = 10;
        retailNumber.Price__c = 199;
        retailNumber.TotalPrice__c = 1990;
        retailNumber.StoreDelivery__c = 20;
        retailNumber.PromoterDailyReport__c = pd.id;
        retailNumber.Status__c = 'new';
        
        //System.debug('rN>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.....'+retailNumber);
        insert retailNumber;
        
        Test.startTest();
        insert pd2;
        pd.Status__c = 'Approved';
        update pd;
        Test.stopTest();
        
    }

}