@isTest
private class InsertSellOutInventoryFileSchedulableTes {
    static testMethod void testMethod1() {

        Sell_out_Inventory__c m = new Sell_out_Inventory__c();
        m.create_dt__c = '2024-05-01 00:00:00';
        insert m;
        Datetime s = Date.valueOf('2024-05-01 08:00:00');
        Datetime e = Date.valueOf('2024-05-02 08:00:00');
        InsertSellOutInventoryFileSchedulable cis = new InsertSellOutInventoryFileSchedulable('111','2024-05-01 00:00:00',true);
        SchedulableContext sc;
        cis.execute(sc);

    }

    static testMethod void testMethod2() {


        InsertSellOutInventoryFileSchedulable cis1 = new InsertSellOutInventoryFileSchedulable('111','1');
        SchedulableContext sc1;
        cis1.execute(sc1);

    }

    static testMethod void testMethod3() {

        Datetime s = Date.valueOf('2024-05-01 08:00:00');
        Datetime e = Date.valueOf('2024-05-02 08:00:00');
        InsertSellOutInventoryFileSchedulable cis = new InsertSellOutInventoryFileSchedulable('111','2024-05-01 00:00:00',true);
        SchedulableContext sc;
        cis.execute(sc);
    }
}