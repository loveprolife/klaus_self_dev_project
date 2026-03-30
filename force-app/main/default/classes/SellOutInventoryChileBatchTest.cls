@isTest
private class SellOutInventoryChileBatchTest{
    static testMethod void testMethod1(){
        BIPT_Chile_sell_out_Inventory__c bi = new BIPT_Chile_sell_out_Inventory__c();
        bi.ch_store_name__c = 'P.VESPUCIO';
        bi.ch_store_no__c = '7200';
        bi.cust_model__c = '43A6K';
        bi.tot_soh__c = '1';
        bi.create_dt__c = '2024-04-27 00:00:00';
        bi.create_dt_date__c = Date.today().addDays(-10);
        INSERT bi;

        BIPT_Chile_sell_out_Inventory__c bi1 = new BIPT_Chile_sell_out_Inventory__c();
        bi1.ch_store_name__c = 'P.VESPUCIO';
        bi1.ch_store_no__c = '72001';
        bi1.cust_model__c = '43A6K1';
        bi1.tot_soh__c = '1';
        bi1.create_dt__c = '2024-04-27 00:00:00';
        bi1.create_dt_date__c = Date.today().addDays(-10);
        INSERT bi1;

        BIPT_Chile_sell_out_Inventory__c bi2 = new BIPT_Chile_sell_out_Inventory__c();
        bi2.ch_store_name__c = 'P.VESPUCIO';
        bi2.ch_store_no__c = '7200';
        bi2.cust_model__c = '43A6K';
        bi2.tot_soh__c = '2';
        bi2.create_dt__c = '2024-04-28 00:00:00';
        bi2.create_dt_date__c = Date.today().addDays(-9);
        INSERT bi2;

        Inventory_Chile__c ic = new Inventory_Chile__c();
        ic.BIPT_Chile_sell_out_Inventory__c = bi.Id;
        ic.Key__c = '7200-43A6K';
        ic.Last_Date__c = Date.valueOf('2024-04-27 00:00:00');
        INSERT ic;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        productTest.Name = '43A6K';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'DELOITTE';
        productTest.Sales_Region__c = 'Hisense Chile';
        Insert productTest;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Shop_Code_Text__c = '7200';
        shop.Sales_Region__c = 'Hisense Chile';
        INSERT shop;


        Database.executeBatch(new SellOutInventoryChileBatch());

        SchedulableContext sc;
        SellOutInventoryChileBatchSchedule asp = new SellOutInventoryChileBatchSchedule();
        asp.execute(sc);
    }

}