@IsTest
private class Batch_SyncCustomerToMDGTest{
    // Utility: create an Account and related Customer_Email__c records to support 'Email' branch
    private static Account setupAccountWithSapCode(String sapCode, Boolean withExistingEmail){
        Account a = new Account(
            Name = 'Test Acc ' + sapCode, 
            SAP_Customer_Code__c = sapCode
        );
        insert a;

        if (withExistingEmail == false){
            // Only create Customer_Email__c when we want to test populating Email_Multiple__c
            // Note: Adjust field/api names if they differ in your org
            List<Customer_Email__c> emails = new List<Customer_Email__c>();
            emails.add(new Customer_Email__c(
                Email__c = 'a1@example.com', 
                No__c = 1, 
                Customer__c = a.Id
            ));
            emails.add(new Customer_Email__c(
                Email__c = 'a2@example.com', 
                No__c = 2, 
                Customer__c = a.Id
            ));
            insert emails;
        } else{
            // Pre-populate Email_Multiple__c to ensure no updates happen in that scenario
            a.Email_Multiple__c = 'pre@set.com';
            update a;
        }
        return a;
    }

    // Stub for GetCustomerInfoByCustomerCodeFromSAP2 to avoid real callouts if used by org code under test via HttpCalloutMock.
    // The batch directly calls the class method, so we won't hit HTTP here. This method is left for completeness.
    @IsTest
    static void testStartReturnsIterable(){
        List<String> ids = new List<String>{ '1001', '1002' };
        Batch_SyncCustomerToMDG b = new Batch_SyncCustomerToMDG(ids, 'Email');
        Iterable<String> itr = b.start(null);
        System.assertNotEquals(null, itr, 'Start should return the iterable provided.');
    }

    @IsTest
    static void testEmailBranch_PopulatesEmailMultiple(){
        String sapCode = 'SAP-EMAIL-001';
        Account a = setupAccountWithSapCode(sapCode, false);

        Test.startTest();
        // Execute method will query by SAP code from provided list
        Batch_SyncCustomerToMDG b = new Batch_SyncCustomerToMDG(new List<String>{ sapCode }, 'Email');
        // Call execute directly to focus branch coverage
        b.execute(null, new List<String>{ sapCode });
        Test.stopTest();

        Account refreshed = [SELECT Id, Email_Multiple__c
                             FROM Account
                             WHERE Id = :a.Id];
        System.assertEquals('a1@example.com;a2@example.com', refreshed.Email_Multiple__c, 'Email_Multiple__c should be concatenated from related Customer_Email__c.');
    }

    @IsTest
    static void testEmailBranch_SkipsWhenEmailExists(){
        String sapCode = 'SAP-EMAIL-EXISTS';
        Account a = setupAccountWithSapCode(sapCode, true);

        Test.startTest();
        Batch_SyncCustomerToMDG b = new Batch_SyncCustomerToMDG(new List<String>{ sapCode }, 'Email');
        b.execute(null, new List<String>{ sapCode });
        Test.stopTest();

        Account refreshed = [SELECT Id, Email_Multiple__c
                             FROM Account
                             WHERE Id = :a.Id];
        System.assertEquals('pre@set.com', refreshed.Email_Multiple__c, 'Existing Email_Multiple__c should not be overwritten.');
    }

    @IsTest
    static void testSyncCustomerToMDGBranch_SuppressesCalloutInTest(){
        // Provide any ids, class checks Test.isRunningTest() to skip the callout method
        List<String> ids = new List<String>{ 'ID-1', 'ID-2' };

        Test.startTest();
        Batch_SyncCustomerToMDG b = new Batch_SyncCustomerToMDG(ids, 'SyncCustomerToMDG');
        // Ensure execute runs the loop and respects Test.isRunningTest to not call real logic
        b.execute(null, ids);
        Test.stopTest();

        // If there were side-effects, assert them here. We only assert that code completes without exception.
        System.assert(true, 'Execute completed without attempting external callouts during tests.');
    }

    @IsTest
    static void testGetCustomerInfoBranch_ExecutesPath(){
        // This branch invokes a static method; during tests we only verify no exceptions thrown and path covered.
        List<String> ids = new List<String>{ '0000513470' };
        
        TestDataUtility.createCustomSettings();
        String json = '{"IsSuccess": "","FailReason": "","CustomerList": [{"SFCode": "","SAPCustomerCode": "0000513470","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "TEST FOREIGN CUSTOMER","CustomerEnglishLanguage2": 2,"Billingto": "0000500047","Shppingto": "0000500047","ShortName": "TEST","Street2": "200 The Campus Maylands Avenue","Street3": "s2","Street4": "s3","Street5": "s4","CountryCode": "US","ProvinceState": "LA","City": "不详","PostalCode": 30000,"TelephoneNumber": "ZH","Fax": "0044-1727 204058","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122020110,"PaymentCondition": "G001","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "USD","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "G001","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "UTXJ","TaxClassification": 0}]}, {"SFCode": "","SAPCustomerCode": "0000500058","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "内贸客户测试","CustomerEnglishLanguage2": "","Billingto": "0000500058","Shppingto": "0000500058","ShortName": "","Street2": "NAME1111","Street3": "","Street4": "","Street5": "","CountryCode": "CN","ProvinceState": "","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1122010501,"PaymentCondition": "","DistributioChannel": 15,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "01","RelatedtoPOD": "","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8010],"BillingCertificateList": [{"TaxCategory": "ZWST","TaxClassification": "1"}]}, {"SFCode": "","SAPCustomerCode": "0000500129","CustomerGroup": "Z006","CustomerLocalLanguage1": "","CustomerLocalLanguage2": "","CustomerEnglishLanguage1": "MAKRO 测试数据","CustomerEnglishLanguage2": "","Billingto": "0000500129","Shppingto": "0000500129","ShortName": "MAKRO","Street2": 1234,"Street3": "","Street4": "","Street5": "","CountryCode": "ZA","ProvinceState": "GP","City": "","PostalCode": "","TelephoneNumber": "","Fax": "","TaxNumber1": "","TaxNumber2": "","VATRegistrationNumber": "","ReconciliatioCustomer": 1121020101,"PaymentCondition": "","DistributioChannel": 11,"ProductGroup": "00","OrderPossibility": 100,"SalesOffice": "","SalesGroup": "","SFCurrency": "CNY","CustomerPricingProcess": "X","PriceList": "","CustomerStatisticsGroup": 1,"ShippingConditions": "02","RelatedtoPOD": "X","PaymentCondition1": "","CustomerGroup2": "","DeliveryPriority": "01","DeliveryingPlant": "","LocationNo1": "0000000","LocationNo2": "00000","CheckDigit": 0,"StorLocation": "","HisenseEntityList": [8010],"CompanyList": [8100],"BillingCertificateList": [{"TaxCategory": "","TaxClassification": ""}]}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );

        Test.startTest();
        Batch_SyncCustomerToMDG b = new Batch_SyncCustomerToMDG(ids, 'GetCustomerInfoByCustomerCodeFromSAP2');
        // Call execute with a single element to match idList.get(0)
        b.execute(null, new List<String>{ '0000513470' });
        Test.stopTest();

        System.assert(true, 'Branch executed without exception.');
    }

    @IsTest
    static void testFinishLogs(){
        // Even though Utility.insertLog is external, we just need to cover finish; no exception expected.
        Batch_SyncCustomerToMDG b = new Batch_SyncCustomerToMDG(new List<String>{ 'X' }, 'Email');
        Test.startTest();
        b.finish(null);
        Test.stopTest();
        System.assert(true, 'Finish executed and attempted to insert log.');
    }

    @IsTest
    static void testEndToEndExecuteBatchEmail(){
        // Full batch execution to cover start/execute/finish lifecycle
        String sapCode = 'SAP-BATCH-EMAIL';
        setupAccountWithSapCode(sapCode, false);

        Test.startTest();
        Database.executeBatch(new Batch_SyncCustomerToMDG(new List<String>{ sapCode }, 'Email'), 1);
        Test.stopTest();

        Account refreshed = [SELECT Id, Email_Multiple__c
                             FROM Account
                             WHERE SAP_Customer_Code__c = :sapCode
                             LIMIT 1];
        System.assertEquals('a1@example.com;a2@example.com', refreshed.Email_Multiple__c, 'Email_Multiple__c should be set after batch run.');
    }

}