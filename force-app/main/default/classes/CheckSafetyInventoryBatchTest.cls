@isTest(SeeAllData=true)
public without sharing class CheckSafetyInventoryBatchTest {
    @isTest
    static void testMthod1(){
        
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        INSERT user1;

        Account testAcc = new Account();
        testAcc.Name = 'test';
        Insert testAcc;

        Gridding__c gird1 = new Gridding__c();
        gird1.Name = '中国重庆';
        gird1.Gridding_Level__c = 'A';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;

        Shop__c shopTest = new Shop__c();
        shopTest.Grid__c = gird1.id;
        shopTest.Account__c = testAcc.Id;
        shopTest.Shop_Level__c = 'A';
        shopTest.Name = '重庆渝中关岳庙店';
        INSERT shopTest;

        Product__c productTest = new Product__c();
        productTest.Name = 'NTC-33K';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'DELOITTE';
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Insert productTest;

        Inventory__c inventoryTestStore = new Inventory__c();
        Id idStore = Schema.SObjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
        inventoryTestStore.RecordTypeId = idStore;
        //inventoryTestStore.Name = '测试库存1';
        inventoryTestStore.Product__c = productTest.id;
        inventoryTestStore.Shop__c = shopTest.Id;
        inventoryTestStore.Customer__c = testAcc.id;
        inventoryTestStore.InitialStock__c = 3;
        inventoryTestStore.Inventory_Number__c = 1; 	 
        inventoryTestStore.SafetyInventory__c = 10;
        inventoryTestStore.SendInventoryWarning__c = true;
        Insert inventoryTestStore;

        Inventory__c inventoryTestCustomer = new Inventory__c();
        Id idCustomer = Schema.SObjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
        inventoryTestCustomer.RecordTypeId = idCustomer;
        //inventoryTestCustomer.Name = '测试库存2';
        inventoryTestCustomer.Product__c = productTest.id;
        inventoryTestCustomer.Shop__c = shopTest.Id;
        inventoryTestCustomer.Customer__c = testAcc.id;
        inventoryTestCustomer.InitialStock__c = 1;
        inventoryTestCustomer.Inventory_Number__c = 2; 	 
		//inventoryTestCustomer.RealStock__c = 10;
        inventoryTestCustomer.SafetyInventory__c = 10;
        //inventoryTestCustomer.InventoryWarning__c = true;
        inventoryTestCustomer.SendInventoryWarning__c = true;
        Insert inventoryTestCustomer;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.UserEmail__c = 'test9934@qq.com';
        rp.Shop_Name__c = shopTest.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        INSERT rp; 

        ResponsibleManager__c testResponsibleManager1 = new ResponsibleManager__c();
        testResponsibleManager1.ResponsiblePerson__c = user1.id;
        testResponsibleManager1.RecordTypeId = Schema.SObjectType.ResponsibleManager__c.getRecordTypeInfosByDeveloperName().get('Grid').getRecordTypeId();
        testResponsibleManager1.Customer__c = testAcc.id;
        Insert testResponsibleManager1;

        ResponsibleManager__c testResponsibleManager2 = new ResponsibleManager__c();
        testResponsibleManager2.ResponsiblePerson__c = user1.id;
        testResponsibleManager2.RecordTypeId = Schema.SObjectType.ResponsibleManager__c.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        testResponsibleManager2.Customer__c = testAcc.id;
        Insert testResponsibleManager2;

        //Database.BatchableContext bc = new Batabase.BatchableContext();
        
        Test.startTest();
        CheckSafetyInventoryBatch testBatch  = new CheckSafetyInventoryBatch();
        Database.executeBatch(testBatch);
        Test.stopTest();

        //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+productInventoryList);
        //System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'+storeStockInventoryList);
        //System.debug('+++++++++++++++++++++++++++++++++'+shopIdList);
        //System.debug('{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}'+customerIdList);
        //
        //System.debug('??????????????????????????????????'+productInventoryList);
        //System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'+responsibleManaggerMap);
    }
}