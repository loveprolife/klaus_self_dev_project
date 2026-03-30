@isTest
private class SAPGetInvoiceLogSchedulableTest{
    static testMethod void testMethod1() {
        Test.startTest();
        new SAPGetInvoiceLogSchedulable('8110', 'ALL');
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        List<String> companyCodeList = new List<String>();
        companyCodeList.add('8110');
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ALL');
        Test.startTest();  
        new SAPGetInvoiceLogSchedulable(companyCodeList, orderTypeCodeList);
        Test.stopTest();
    }

}