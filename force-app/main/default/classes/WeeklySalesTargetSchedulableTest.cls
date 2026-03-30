@isTest
public with sharing class WeeklySalesTargetSchedulableTest {
    @isTest
    public static void testWeeklySalesTargetSchedulableTest1() {
        Test.startTest();
        WeeklySalesTargetSchedulable cis1 = new WeeklySalesTargetSchedulable('WeeklySalesTargetSchedulable', 22, 'channel');
        SchedulableContext sc1;
        cis1.execute(sc1);
        Test.stopTest();
    }
    @isTest
    public static void testWeeklySalesTargetSchedulableTest2() {
        Test.startTest();
        WeeklySalesTargetSchedulable cis1 = new WeeklySalesTargetSchedulable('WeeklySalesTargetSchedulable', 0, 'dailySales');
        SchedulableContext sc1;
        cis1.execute(sc1);
        Test.stopTest();
    }
}