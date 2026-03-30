@isTest
private class GetThaiSellOutInventorySchedulableTest {
    static testMethod void testMethod1() {

        GetThaiSellOutInventorySchedulable cis = new GetThaiSellOutInventorySchedulable('111', '2024-05-01 08:00:00', true,false, '', '');
        SchedulableContext sc;
        cis.execute(sc);

    }

    static testMethod void testMethod2() {


        GetThaiSellOutInventorySchedulable cis1 = new GetThaiSellOutInventorySchedulable('GetThaiSellOutInventorySchedulable', '2024-05-01 08:00:00', 5000, 0, false, '', '');
        SchedulableContext sc1;
        cis1.execute(sc1);

    }

    static testMethod void testMethod3() {

        Thai_Sell_out_Inventory__c soi = new Thai_Sell_out_Inventory__c();
        soi.create_dt__c = '2024-05-01 08:00:00';
        insert soi;

        GetThaiSellOutInventorySchedulable cis = new GetThaiSellOutInventorySchedulable('111', '2024-05-01 08:00:00', true,false, '', '');
        SchedulableContext sc;
        cis.execute(sc);

    }
   
}