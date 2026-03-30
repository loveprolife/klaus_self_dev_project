@isTest
private class SAPInvoiceLogSchedulableTest{
    static testMethod void testMethod1() {
        Test.startTest();
        new SAPInvoiceLogSchedulable('2020-08-01');
        Test.stopTest();
    }

}