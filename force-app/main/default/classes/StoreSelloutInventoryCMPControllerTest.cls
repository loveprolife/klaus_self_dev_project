@isTest
public class StoreSelloutInventoryCMPControllerTest {
  

    @isTest
    static void testMethod1(){
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

        Sell_out_Inventory__c soi1 = new Sell_out_Inventory__c(
            prdln__c = '0110',
            create_dt__c = '2024-09-10',
            Store__c = shop.Id,
            act_qty__c = 1,
            Tot_SOH__c = 1,
            Avl_SOH__c = 1,
            st_intr__c = 1

        );
        insert soi1;
        Sell_out_Inventory__c soi2 = new Sell_out_Inventory__c(
            prdln__c = '0110',
            create_dt__c = '2024-09-10',
            Store__c = shop.Id,
            act_qty__c = 1,
            Tot_SOH__c = 1,
            Avl_SOH__c = 1,
            st_intr__c = 1

        );
        insert soi2;
        Test.startTest();
        StoreSelloutInventoryCMPController.initData(shop.Id);
        Test.stopTest();
    }

    @isTest
    static void testMethod2(){
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

        Sell_out_Inventory__c soi1 = new Sell_out_Inventory__c(
            prdln__c = '0110',
            create_dt__c = '2024-09-10',
            Store__c = shop.Id,
            act_qty__c = 1,
            Tot_SOH__c = 1,
            Avl_SOH__c = 1,
            st_intr__c = 1,
            cust_model__c = '1'

        );
        insert soi1;
        Sell_out_Inventory__c soi2 = new Sell_out_Inventory__c(
            prdln__c = '0110',
            create_dt__c = '2024-09-10',
            Store__c = shop.Id,
            act_qty__c = 1,
            Tot_SOH__c = 1,
            Avl_SOH__c = 1,
            st_intr__c = 1,
            Days_of_Inventory_w4__c = 55,
            cust_model__c = '2'
        );
        Sell_out_Inventory__c soi3 = new Sell_out_Inventory__c(
            prdln__c = '0110',
            create_dt__c = '2024-09-10',
            Store__c = shop.Id,
            act_qty__c = 1,
            Tot_SOH__c = 1,
            Avl_SOH__c = 1,
            st_intr__c = 1,
            Days_of_Inventory_w4__c = 55,
            cust_model__c = '2'
        );
        insert soi3;
        
        Test.startTest();
        StoreSelloutInventoryCMPController.initDetail(shop.Id);
        Test.stopTest();
    }
}