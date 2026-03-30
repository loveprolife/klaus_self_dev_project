@isTest
private class SetThaiActQtyBatchSchedulableTest {
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

        Thai_Sell_out_Inventory__c soi1 = new Thai_Sell_out_Inventory__c(
            prdln__c = '0110',
            create_dt__c = '2024-09-10',
            Store__c = shop.Id,
            act_qty__c = '1',
            Tot_SOH__c = '1',
            Avl_SOH__c = '1',
            st_intr__c = '1',
            cust_model__c = '1'

        );
        insert soi1;

        SetThaiActQtyBatchSchedulable cis = new SetThaiActQtyBatchSchedulable('111');
        SchedulableContext sc;
        cis.execute(sc);

    }
   
}