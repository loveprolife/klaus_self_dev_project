@isTest
private class ShopExternalKeyBatchTest {
    
    static testMethod void testHandler() {

        Account acc = new Account();
        acc.Name = 'KS';
        acc.SAP_Customer_Code__c = '0001';
		INSERT acc;
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
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
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird2.id;
        shop.Store_No_from_Account__c = '01';
        shop.City__c = '北京市';
        INSERT shop;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'B';
        shop1.Grid__c = gird2.id;
        INSERT shop1;

        gird1.Gridding_Code__c = 'J01-J002';
        UPDATE gird1;

        ShopExternalKeyBatch scr = new ShopExternalKeyBatch();
        Database.executeBatch(scr,200);
    }
}