@isTest
private class GetBIPTChileSellOutInventorySduTest {
    static testMethod void testMethod1() {

        Date s = Date.valueOf('2024-05-01');
        Date e = Date.valueOf('2024-05-02');
        GetBIPTChileSellOutInventorySchedulable cis = new GetBIPTChileSellOutInventorySchedulable('111',s,e);
        SchedulableContext sc;
        cis.execute(sc);

    }

    static testMethod void testMethod2() {


        GetBIPTChileSellOutInventorySchedulable cis1 = new GetBIPTChileSellOutInventorySchedulable('111','1');
        SchedulableContext sc1;
        cis1.execute(sc1);

    }

    static testMethod void testMethod3() {


        GetBIPTChileSellOutInventorySchedulable cis2 = new GetBIPTChileSellOutInventorySchedulable('111','2');
        SchedulableContext sc2;
        cis2.execute(sc2);
    }
}