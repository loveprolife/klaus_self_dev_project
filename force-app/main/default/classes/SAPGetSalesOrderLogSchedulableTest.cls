@isTest
private class SAPGetSalesOrderLogSchedulableTest{

    static testMethod void testMethod1() {
        Test.startTest();
        new SAPGetSalesOrderLogSchedulable('2020-08-01');
        Test.stopTest();
    }

}