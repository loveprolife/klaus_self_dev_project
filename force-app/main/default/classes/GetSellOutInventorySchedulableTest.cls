@isTest
private class GetSellOutInventorySchedulableTest {
    static testMethod void testMethod1() {

        GetSellOutInventorySchedulable cis = new GetSellOutInventorySchedulable('111', '2024-05-01 08:00:00', true,false, '', '');
        SchedulableContext sc;
        cis.execute(sc);

    }

    static testMethod void testMethod2() {


        GetSellOutInventorySchedulable cis1 = new GetSellOutInventorySchedulable('GetSellOutInventorySchedulable', '2024-05-01 08:00:00', 5000, 0, false, '', '');
        SchedulableContext sc1;
        cis1.execute(sc1);

    }

    static testMethod void testMethod3() {

        Sell_out_Inventory__c soi = new Sell_out_Inventory__c();
        soi.create_dt__c = '2024-05-01 08:00:00';
        insert soi;

        GetSellOutInventorySchedulable cis = new GetSellOutInventorySchedulable('111', '2024-05-01 08:00:00', true,false, '', '');
        SchedulableContext sc;
        cis.execute(sc);

    }
   
}