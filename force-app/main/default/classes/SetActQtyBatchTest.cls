@isTest
private class SetActQtyBatchTest {
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

        Sell_out_Inventory__c soi = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-08-29',
            ch_store_no__c = '111',
            cust_model__c = '222',
            Avl_SOH__c = 0,
            act_qty__c = 55
        );
        insert soi;

        Sell_out_Inventory__c soi1 = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-08-29',
            Avl_SOH__c = 0,
            act_qty__c = 55
        );
        insert soi1;

        Sell_out_Inventory__c soi2 = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-08-01',
            act_qty__c = 55,
            ch_store_no__c = '111',
            cust_model__c = '222',
            Avl_SOH__c = 0
        );
        insert soi2;

        Sell_out_Inventory__c soi3 = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-07-18',
            act_qty__c = 55,
            ch_store_no__c = '111',
            cust_model__c = '222',
            Avl_SOH__c = 0
        );
        insert soi3;
        
        SetActQtyBatch ss  =new SetActQtyBatch('2025-08-29');
		Database.executeBatch(ss);
    }

    static testMethod void testMethod2() {

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

        Sell_out_Inventory__c soi = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-08-29',
            ch_store_no__c = '111',
            cust_model__c = '222',
            Avl_SOH__c = 0,
            act_qty__c = 55
        );
        insert soi;

        Sell_out_Inventory__c soi1 = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-08-29',
            Avl_SOH__c = 0,
            act_qty__c = 55
        );
        insert soi1;

        Sell_out_Inventory__c soi2 = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-08-01',
            act_qty__c = 55,
            ch_store_no__c = '111',
            cust_model__c = '222',
            Avl_SOH__c = 0
        );
        insert soi2;

        Sell_out_Inventory__c soi3 = new Sell_out_Inventory__c(
            Store__c = shop.Id,
            create_dt__c = '2025-07-18',
            act_qty__c = 55,
            ch_store_no__c = '111',
            cust_model__c = '222',
            Avl_SOH__c = 0
        );
        insert soi3;
        
        SetActQtyBatch ss1  =new SetActQtyBatch();
		Database.executeBatch(ss1);
    }
}