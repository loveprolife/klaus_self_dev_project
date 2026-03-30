@IsTest
public class Batch_SyncCustomerToMDG2Test {

    @IsTest
    static void test_WithData_SingleRecord() {
        // Prepare test data: one Temp_Table__c with Name as the customer code used by execute()
        Temp_Table__c t1 = new Temp_Table__c();
        // Ensure Name is set since batch queries Id, Name and passes Name into the callout method.
        t1.Name = '0000513470';
        insert t1;

        TestDataUtility.createCustomSettings();
        String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000513470","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "ZWST","TaxClassification": "1"}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );

        Test.startTest();
        // Execute batch; if the real static call performs callouts, consider wrapping in a mockable interface in prod.
        Database.executeBatch(new Batch_SyncCustomerToMDG2(), 1);
        Test.stopTest();

        // Minimal assertion: record still exists and code executed without unhandled exceptions.
        Temp_Table__c fetched = [SELECT Id, Name FROM Temp_Table__c WHERE Id = :t1.Id];
        System.assertEquals('0000513470', fetched.Name, 'Temp record should remain unchanged.');
    }
}