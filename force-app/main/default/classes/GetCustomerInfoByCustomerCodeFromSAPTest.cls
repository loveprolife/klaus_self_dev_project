@isTest
private class GetCustomerInfoByCustomerCodeFromSAPTest{
    static testMethod void testMethod1(){
        TestDataUtility.createCustomSettings();
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000500047', '0000500047', 'Hisense USA');
        Test.startTest();
        String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000513469","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo('0000513469', '2019-01-01', '2019-01-01', null);
        Test.stopTest();
    }

    static testMethod void testMethod2(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"IsSuccess": "False","FailReason": "","CustomerList": []}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo('0000513472', '2019-01-01', '2019-01-01', '');
        Test.stopTest();
    }

    static testMethod void testMethod3(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"IsSuccess" "False","FailReason": "","CustomerList": []}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo('0000513464', '2019-01-01', '2019-01-01', '');
        Test.stopTest();
    }

    static testMethod void testMethod4(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000513470","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo('0000513470', '2019-01-01', '2019-01-01', '');
        Test.stopTest();
    }

    static testMethod void testMethod5(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"IsSuccess": "No data","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000513470","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo('0000513470', '2019-01-01', '2019-01-01', '');
        Test.stopTest();
    }

    static testMethod void testMethod6(){
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

        String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000513470","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "ZWST","TaxClassification": "1"}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP.getCustomerInfo('0000513470', '2019-01-01', '2019-01-01', '8010');
        Test.stopTest();
    }

    static testMethod void testMethod7(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8440';
        tcm.Country__c = 'IN';
        insert tcm;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'IN';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'ZWST';
        insert ntc;

        National_tax_category__c ntc1 = new National_tax_category__c();
        ntc1.National_code__c = 'IN';
        ntc1.sort__c = 2;
        ntc1.Tax_category__c = 'ZTCS';
        insert ntc1;

        Tax_category__c tc = new Tax_category__c();
        tc.name = '0';
        tc.Tax_category__c = 'ZWST';
        tc.Tax_Catagoery_External_Id__c = 'ZWST0';
        insert tc;

        Tax_category__c tc1 = new Tax_category__c();
        tc1.name = '1';
        tc1.Tax_category__c = 'ZTCS';
        tc1.Tax_Catagoery_External_Id__c = 'ZTCS1';
        insert tc1;

        String json = '{"IsSuccess":"","FailReason":"True","CustomerList":[{"SFCode":"","SAPID":"","CustomerLocalLanguage2":"xx","CustomerEnglishLanguage2":"11","ShortName":"11","Street3":"11","Street4":"11","Street5":"11","ORT02":"11","ZZTOWN":"11","PostalCode":"11","TelephoneNumber":"11","Fax":"11","TaxNumber1":"11","TaxNumber2":"11","VATRegistrationNumber":"11","LIFNR":"11","KATR3":"","KATR2":"","KDGRP":"","ZZSH":"11","ZZFONM":"11","ZZRENO":"11","SMTP_ADDR":"11","ZZCVCO":"11","ZZCHCUSCA":"10","ZZCHCUSSU":"103","ZZCRERAT":"11","ZZHWKHFJ":"11","LZONE":"11","ZSORT2":"11","ZTAX_CODE3":"11","ZTAX_CODE4":"11","ZZFHLX":"","ZZFHYY":"11","SAPCustomerCode":"0000203914","SAPCustomerCode2":"","CustomerGroup":"Z003","CustomerLocalLanguage1":"USD客户reclassification","CustomerEnglishLanguage1":"USD客户reclassification","Street2":"USD客户reclassification","CountryCode":"IN","ProvinceState":"01","City":"USD客户reclassification","PARTNER":"0000203914","BU_GROUP":"Z003","BU_LANGU":"ZH","LocationNo1":"0000000","LocationNo2":"00000","CheckDigit":0,"BBBNR":"0000000","BBSNR":"00000","BUBKZ":0,"ZZLINE":10,"ORT01":"USD客户reclassification","CUTSOMER_TYPE":"","EBusOrNot":10,"Name3":"","CompanyList":[{"BUKRS":8440,"RECONCILIATIOCUSTOMER":1122010501,"PAYMENTCONDITION":"","STORLOCATION":"","ZWELS":"","KVERM":"","NODEL":"","ZZSORT1":"","ZZSORT2":"","EDI_TYPE":"","ZTV":"","ZVALID_TO":"00000000","PACKAGING_TYPE":""},{"BUKRS":8520,"RECONCILIATIOCUSTOMER":1122010201,"PAYMENTCONDITION":"","STORLOCATION":"","ZWELS":"","KVERM":"","NODEL":"","ZZSORT1":"","ZZSORT2":"","EDI_TYPE":"","ZTV":"","ZVALID_TO":"00000000","PACKAGING_TYPE":""}],"SALES":[{"VKORG":8440,"DISTRIBUTIOCHANNEL":11,"PRODUCTGROUP":"00","ORDERPOSSIBILITY":100,"SALESOFFICE":"","SALESGROUP":"","SFCURRENCY":"INR","CUSTOMERPRICINGPROCESS":"X","PRICELIST":"","CUSTOMERSTATISTICSGROUP":1,"SHIPPINGCONDITIONS":"02","RELATEDTOPOD":"X","PAYMENTCONDITION1":"OA60","DELIVERYPRIORITY":"","DELIVERYINGPLANT":"","CUSTOMERGROUP2":"","KDGRP":"","AUFSD":"","KONDA":"","INCO1":"","INCO2":"","ZKVGR1":"","ZKVGR3":"","ZKVGR4":"","ZKVGR5":"","KTGRD":"","PAYER":"0000203914","RECEIVER":"0000203914","TAX":[{"TAXCOUNTRY":"IN","TAXCATEGORY":"ZTCS","TAXCLASSIFICATION":0},{"TAXCOUNTRY":"IN","TAXCATEGORY":"ZWST","TAXCLASSIFICATION":0}]}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );
        GetCustomerInfoByCustomerCodeFromSAP1.getCustomerInfo('0000513470', '2019-01-01', '2019-01-01');
        GetCustomerInfoByCustomerCodeFromSAP2.getCustomerInfo('0000513470', '2019-01-01', '2019-01-01');
        Test.stopTest();
    }

}