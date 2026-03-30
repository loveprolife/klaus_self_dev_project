@isTest
public with sharing class InventoryItemTriggerHandlerTest {
    
       static String inRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
       static String outRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
    static String gridInventoryRTId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('GridInventory').getRecordTypeId();
    static String productRTId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    static String giftProductRTId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
    
    @isTest
    static void TestInventoryItemTrigger(){
       Product__c productTest = new Product__c();
       productTest.Name = 'NTC-22E';
       productTest.CurrencyIsoCode = 'USD';
       productTest.Product_External_Id__c = 'NTC-22E-jp';
        productTest.RecordTypeId = productRTId;
       Insert productTest;
        SYstem.debug('productTest='+productTest);
       Account customerTest = new Account();
       customerTest.Name = '测试客户1';
       Insert customerTest;
       Shop__c shopTest = new Shop__c();
       shopTest.Name = '测试门店1';
       shopTest.City__c = '重庆';
       shopTest.Account__c = customerTest.id;
       shopTest.Shop_Level__c = 'A';
       Insert shopTest;
       
       
       Inventory__c inventoryTestStore = new Inventory__c();
       Id idStore = Schema.SObjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
       inventoryTestStore.RecordTypeId = idStore;
       //inventoryTestStore.Name = '测试库存1';
       inventoryTestStore.Product__c = productTest.id;
       inventoryTestStore.Shop__c = shopTest.Id;
        inventoryTestStore.Customer__c = customerTest.Id;
       inventoryTestStore.Inventory_Number__c = 1;
       Insert inventoryTestStore;
       
       Inventory__c inventoryTestCustomer = new Inventory__c();
       Id idCustomer = Schema.SObjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
       inventoryTestCustomer.RecordTypeId = idCustomer;
       //inventoryTestCustomer.Name = '测试库存2';
       inventoryTestCustomer.Product__c = productTest.id;
       inventoryTestCustomer.Shop__c = shopTest.Id;
       inventoryTestCustomer.Customer__c = customerTest.id;
       inventoryTestCustomer.Inventory_Number__c = 1;
       Insert inventoryTestCustomer;
       StockItem__c stockItemTestStore = new StockItem__c();
        stockItemTestStore.Type__c = 'IN';
        stockItemTestStore.inventory__c = inventoryTestStore.Id;
        stockItemTestStore.Quantity__c = 1;
        stockItemTestStore.RecordTypeId = inRecordId ;
        insert stockItemTestStore;
       List<StockItem__c> stockItemList = new List<StockItem__c>();
       
       stockItemTestStore = new StockItem__c();
        stockItemTestStore.inventory__c = inventoryTestStore.Id;
       stockItemTestStore.Quantity__c= 1;
       stockItemTestStore.Product__c = productTest.Id;
       stockItemTestStore.Shop__c = shopTest.id;
        stockItemTestStore.Type__c = 'IN';
       stockItemTestStore.RecordTypeId = inRecordId ;
       stockItemTestStore.ApprovalStatus__c = 'Approved';
        //insert stockItemTestStore;
       stockItemList.add(stockItemTestStore);
       
       StockItem__c stockItemTestCustomer = new StockItem__c();
       stockItemTestCustomer.Quantity__c = 1;
       stockItemTestCustomer.Product__c = productTest.Id ;
       stockItemTestCustomer.Customer__c = customerTest.id;
       stockItemTestCustomer.RecordTypeId  = outRecordId ;
       stockItemTestCustomer.ApprovalStatus__c = 'Approved';
        stockItemTestCustomer.Type__c = 'IN';
       stockItemList.add(stockItemTestCustomer);
        System.debug('stockItemTestCustomer='+stockItemTestCustomer);
        
       StockItem__c stockItemOutTestStore = new StockItem__c();
       stockItemOutTestStore.Quantity__c= 1;
       stockItemOutTestStore.Product__c = productTest.Id;
       //stockItemOutTestStore.Shop__c = shopTest.id;
       stockItemOutTestStore.RecordTypeId = outRecordId ;
       stockItemOutTestStore.ApprovalStatus__c = 'Approved';
        stockItemOutTestStore.Type__c = 'IN';
       stockItemList.add(stockItemOutTestStore); 
       
        Gridding__c gd = new Gridding__c(Name='Indonesia');
        insert gd;
        Product__c product1 = new Product__c();
       product1.Name = 'NTC-22E';
       product1.CurrencyIsoCode = 'USD';
       product1.Product_External_Id__c = 'NTC321-22E-jp';
        product1.RecordTypeId = giftProductRTId;
       Insert product1;
        stockItemOutTestStore = new StockItem__c();
       stockItemOutTestStore.Quantity__c= 1;
       stockItemOutTestStore.Product__c = product1.Id;
       stockItemOutTestStore.GiftGrid__c = gd.id;
       stockItemOutTestStore.RecordTypeId = gridInventoryRTId ;
       stockItemOutTestStore.ApprovalStatus__c = 'Approved';
        stockItemOutTestStore.Type__c = 'IN';
       stockItemList.add(stockItemOutTestStore); 
        
       Test.startTest();
       Database.insert(stockItemList);
        stockItemTestCustomer.Quantity__c = 2;
        update stockItemTestCustomer;
       Test.stopTest();
       
       System.debug('Update Successed!');
   }
    
}