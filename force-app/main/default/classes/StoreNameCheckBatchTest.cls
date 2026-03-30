@isTest
private class StoreNameCheckBatchTest {
    static testMethod void testMethod1() {

        Account acc = new Account(Name = 'testname');
        insert acc;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Japan';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店1';
        shop1.City__c = '北京市';
        shop1.Sales_Region__c = 'Hisense Japan';
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop1;

        StoreNameCheckBatch ss  =new StoreNameCheckBatch();
		Database.executeBatch(ss);
    }
}