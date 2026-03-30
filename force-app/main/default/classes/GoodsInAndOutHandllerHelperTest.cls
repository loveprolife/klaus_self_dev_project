@isTest
public class GoodsInAndOutHandllerHelperTest {
    static String giftProduct =  Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
    static String japanProduct = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
	@isTest
    static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Gridding__c testGridding = new Gridding__c();
        testGridding.Name = '中国重庆';
        testGridding.CurrencyIsoCode = 'USD';
        testGridding.Gridding_Level__c = 'A';
        Insert testGridding;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '测试门店';
        shop1.GiftGrid__c = testGridding.id;
        INSERT shop1;
        
        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
       	Insert productTest;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  acc.id;
        testReport1.Shop__c = shop1.id;
        //testReport1.ExternalId__c = String.valueOf('%'+parExId);
        //testReport.Name = '测试PromoterShare用';
        Insert testReport1;
        
        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = shop1.id;
        testRetailNumber.Product__c = productTest.id;
        testRetailNumber.Number__c = 100;
        testRetailNumber.Price__c = 199;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = acc.id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        Insert testRetailNumber;
        
        //Retail_Number__c testDS = new Retail_Number__c();
            
        //Promoter_Daily_Report__c testPDR = [select id from Promoter_Daily_Report__c limit 1];
        //Retail_Number__c testDS = [select id from Retail_Number__c limit 1];
        
        GoodsInOut__c testGoodsInOut1 = new GoodsInOut__c();
        //testGoodsInOut1.Status__c = 'Approved';
        testGoodsInOut1.Quantities__c = 2;
        testGoodsInOut1.DailySales__c = testRetailNumber.id;
        testGoodsInOut1.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut1.RecordTypeId = Schema.SobjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        //testGoodsInOut.ProductType__c = 'Gift';
        testGoodsInOut1.ProductModel__c = productTest.id;
        testGoodsInOut1.StroeCode__c = shop1.id;
        testGoodsInOut1.Status__c = 'new';
        
        GoodsInOut__c testGoodsInOut2 = new GoodsInOut__c();
        //testGoodsInOut2.Status__c = 'Approved';
        testGoodsInOut2.Quantities__c = 1;
        testGoodsInOut2.DailySales__c = testRetailNumber.id;
        testGoodsInOut2.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut2.RecordTypeId = Schema.SobjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('Out').getRecordTypeId();
        testGoodsInOut2.ProductModel__c = productTest.id;
        testGoodsInOut2.StroeCode__c = shop1.id;
        testGoodsInOut2.Status__c = 'Submitted';
        

        Test.startTest();
        System.debug(testGoodsInOut1.Status__c);
        Insert testGoodsInOut1;
        GoodsInOut__c updateGoodsInOut = [Select id,Status__c,Quantities__c,DailySales__c From GoodsInOut__c Where Status__c = 'new' Limit 1];
        updateGoodsInOut.Status__c = 'Approved';
        update updateGoodsInOut;
        Insert testGoodsInOut2;
        Test.stopTest();
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
        retailNumber.GiftQuantity__c = 1;
        retailNumber.Product__c = productTest.id;
        retailNumber.Shop__c = shopTest.id;
        retailNumber.Number__c = 10;
        retailNumber.Price__c = 199;
        retailNumber.TotalPrice__c = 1990;
        retailNumber.StoreDelivery__c = 2;
        retailNumber.PromoterDailyReport__c = pd.id;
        retailNumber.Status__c = 'new';
        
        //System.debug('rN>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.....'+retailNumber);
        insert retailNumber;
        
        Test.startTest();
        insert pd2;
        pd.Status__c = 'Submitted';
        update pd;
        pd.Status__c = 'Approved';
        update pd;

        List<GoodsInOut__c> goodsInOutList = [SELECT Id, Country__c, SalesRegion__c FROM GoodsInOut__c];
        Map<Id, String> errorMap = new Map<Id, String>();
        System.debug('goodsInOutList.size()：' + goodsInOutList.size());
        for(GoodsInOut__c item : goodsInOutList) {
            if(Approval.isLocked(item.Id)) {
                Approval.UnlockResult unlockResult = Approval.unlock(item.Id);
                if(unlockResult.isSuccess()) {
                    item.SalesRegion__c = item.Country__c;
                    item.Quantities__c = 10;
                    Approval.LockResult lockResult = Approval.lock(item.Id);
                    if(!lockResult.isSuccess()) {
                        errorMap.put(item.Id, 'lock error');
                    }
                } else {
                    errorMap.put(item.Id, 'unlock error');
                }
            } else {
                item.SalesRegion__c = item.Country__c;
                item.Quantities__c = 10;
            }
        }
        update goodsInOutList;
        Test.stopTest();
        
    }
}