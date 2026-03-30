@isTest
private class GetCustomerInfoFromSAPTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000500047', '0000500047','Hisense USA');
        Test.startTest();
    	String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000500047","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        //GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"IsSuccess": "False","FailReason": "","CustomerList": []}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"IsSuccess" "False","FailReason": "","CustomerList": []}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }
    static testMethod void testMethod4() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000500047","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('C000');
        companyList.add('8100');
        GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }

    static testMethod void testMethod5() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"IsSuccess": "No data","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000500047","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }

    static testMethod void testMethod6() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json1 = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000500047","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        List<String> companyList = new List<String>();
        companyList.add('8410');
        String dateYesterday = String.valueOf(System.now().addDays(-1).format('yyyy-MM-dd'));
        SystemCallSchedualByABitINMorning.Output getShopOutput = new SystemCallSchedualByABitINMorning.Output();
        getShopOutput.AccountGroup = 'C000';
        getShopOutput.SyncStartDate = dateYesterday;
        getShopOutput.syncEndDate = dateYesterday;
        getShopOutput.CompanyCodeList = new List<String>{'8410'};
        companyList.add(JSON.serialize(getShopOutput));
        GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }

    static testMethod void testMethod7() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8010';
        tcm.Country__c = 'US';
        insert tcm;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'ZWST';
        insert ntc;

        National_tax_category__c ntc1 = new National_tax_category__c();
        ntc1.National_code__c = 'USA';
        ntc1.sort__c = 2;
        ntc1.Tax_category__c = 'ZWST';
        insert ntc1;

        Tax_category__c tc = new Tax_category__c();
        tc.name = '1';
        tc.Tax_category__c = 'ZWST';
        tc.Tax_Catagoery_External_Id__c = 'ZWST1';
        insert tc;

    	String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000500047","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8010');
        GetCustomerInfoFromSAP.getCustomerInfo(companyList,'2019-01-01','2019-01-01');
        Test.stopTest();
    }

}