@isTest
private class ProductTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Product__c productTest = new Product__c();
        productTest.Name = 'NTC-33K';
        productTest.sales_region__c = 'Hisense Chile';
        productTest.recordTypeId = Schema.SObjectType.product__c.getRecordTypeInfosByName().get('Regional Product').getRecordTypeId();
        Insert productTest;

        Product__c productTest1 = new Product__c();
        productTest1.Name = 'NTC-33K1';
        productTest1.sales_region__c = 'Hisense Chile';
        productTest1.recordTypeId = Schema.SObjectType.product__c.getRecordTypeInfosByName().get('Regional Product').getRecordTypeId();
        Insert productTest1;

        productTest.Brand__c = 'Hisense';
        Update productTest;

        Test.stopTest();

    }
}