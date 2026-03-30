@isTest
public class NewSamplingDetailHandlerTest {

    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    
    @isTest
    static void testNewSamplingDetailHandlerTest(){

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Shop__c store2 = new Shop__c();
        store2.Name = 'Hi Fi Corporation NEWCASTLE2';
        store2.Account__c = customer.Id;
        store2.Sales_Region__c = 'Hisense Indonesia';
        insert store2;

        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.sales_region__c = 'Hisense Indonesia';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Test.startTest();

        Sampling_Detail__c detail = new Sampling_Detail__c();
        detail.Shop__c = store.Id;
        detail.Product__c = product.Id;
        detail.AutomaticallyGenerateSampleStandard__c = true;
        insert detail;

        Sampling_Detail__c detail2 = new Sampling_Detail__c();
        detail2.Shop__c = store2.Id;
        detail2.Product__c = product.Id;
        detail2.AutomaticallyGenerateSampleStandard__c = true;
        insert detail2;

        Test.stopTest();

    }
}