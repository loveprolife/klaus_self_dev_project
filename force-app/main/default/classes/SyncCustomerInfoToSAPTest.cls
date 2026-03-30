@isTest
private class SyncCustomerInfoToSAPTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
    	Payment_Term__c paymentTerm = new Payment_Term__c();
    	paymentTerm.Name = 'G490';
    	Database.insert(paymentTerm);

    	Country_State__c countryState = new Country_State__c();
    	countryState.Name = 'Test';
    	countryState.Belong_To__c = 'DZ';
    	Database.insert(countryState);

    	PickList__c pockList = new PickList__c();
    	pockList.Name = 'Test';
    	pockList.Value__c = 'Test';
        Database.insert(pockList);
        
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8300';
        tcm.Country__c = 'US';
        insert tcm;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        National_tax_category__c ntc1 = new National_tax_category__c();
        ntc1.National_code__c = 'USA';
        ntc1.sort__c = 2;
        ntc1.Tax_category__c = 'UTXJ';
        insert ntc1;

    	Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        Database.insert(acc1);

        Account acc2 = new Account();
    	acc2.Name = 'Test Account002Test Account002Test Account002Test Account002Test A';
        acc2.SAP_Customer_Code__c = '177232312';
        acc2.External_Key__c = '1772378988222';
        acc2.Customer_Name_Local_Language__c = '0001';
        Database.insert(acc2);

        Account acc = new Account();
        acc.Name = 'Test Account003';
        acc.SAP_Customer_Code__c = '1234567890';
        acc.External_Key__c = '1234567890';
        acc.Sales_Region__c = 'Hisense USA';
        // acc.Payment_Term__c = paymentTerm.Id;
        acc.Guarantor_Country_Code__c = 'DZ';
        acc.Stor_Location__c = pockList.Id;
        acc.Payer__c = acc1.Id;
        acc.Address__c = 'Test class Address class class class class class class class class class class class class class class class class';
        acc.Customer_Name_Local_Language__c = 'Customer_Name_Local_Language__cCustomer_Name_Local_Language__cCustomer_Name_Lo';
        // acc.Hisense_Entity__c = '8140';
        Database.insert(acc);
        
        Customer_Tax_category__c tax = new Customer_Tax_category__c();
        tax.Customer__c = acc.Id;
        Database.insert(tax);

        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"FailReason":"","IsSuccess":"True","SAPCustomerCode":"0123012301","SFCodeFromSAP":"'+ acc.Customer_SF_Code__c + '"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SyncCustomerInfoToSAP.postCustomerInfomationToSAP(acc.Id);
        SyncCustomerInfoToSAP.postCustomerInfomationToSAP(acc1.Id);
        SyncCustomerInfoToSAP.postCustomerInfomationToSAP(acc2.Id);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();
    	Payment_Term__c paymentTerm = new Payment_Term__c();
    	paymentTerm.Name = 'G490';
    	Database.insert(paymentTerm);

    	Country_State__c countryState = new Country_State__c();
    	countryState.Name = 'Test';
    	countryState.Belong_To__c = 'DZ';
    	Database.insert(countryState);

    	PickList__c pockList = new PickList__c();
    	pockList.Name = 'Test';
    	pockList.Value__c = 'Test';
    	Database.insert(pockList);

    	Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        Database.insert(acc1);

        Account acc = new Account();
        acc.Name = 'Test Account003';
        acc.SAP_Customer_Code__c = '1234567890';
        acc.External_Key__c = '1234567890';
        acc.Sales_Region__c = 'Hisense USA';
        // acc.Payment_Term__c = paymentTerm.Id;
        acc.Guarantor_Country_Code__c = 'DZ';
        acc.Stor_Location__c = pockList.Id;
        acc.Payer__c = acc1.Id;
        acc.Address__c = 'Test class Address class class class class class class class class class class class class class class class class';
        acc.Customer_Name_Local_Language__c = 'Customer_Name_Local_Language__cCustomer_Name_Local_Language__cCustomer_Name_Lo';
        // acc.Hisense_Entity__c = '8140';
        Database.insert(acc);
        
        Customer_Tax_category__c tax = new Customer_Tax_category__c();
        tax.Customer__c = acc.Id;
        Database.insert(tax);
        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"FailReason":"","IsSuccess":"false","SAPCustomerCode":"","SFCodeFromSAP":"001001"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SyncCustomerInfoToSAP.postCustomerInfomationToSAP(acc.Id);
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        TestDataUtility.createCustomSettings();
    	Payment_Term__c paymentTerm = new Payment_Term__c();
    	paymentTerm.Name = 'G490';
    	Database.insert(paymentTerm);

    	Country_State__c countryState = new Country_State__c();
    	countryState.Name = 'Test';
    	countryState.Belong_To__c = 'DZ';
    	Database.insert(countryState);

    	PickList__c pockList = new PickList__c();
    	pockList.Name = 'Test';
    	pockList.Value__c = 'Test';
        Database.insert(pockList);
        
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8300';
        tcm.Country__c = 'US';
        insert tcm;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        National_tax_category__c ntc1 = new National_tax_category__c();
        ntc1.National_code__c = 'USA';
        ntc1.sort__c = 2;
        ntc1.Tax_category__c = 'UTXJ';
        insert ntc1;

    	Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.E_commerce_Customer_Label__c = '10';
        Database.insert(acc1);

        Account acc2 = new Account();
    	acc2.Name = 'Test Account002Test Account002Test Account002Test Account002Test A';
        acc2.SAP_Customer_Code__c = '177232312';
        acc2.External_Key__c = '1772378988222';
        acc2.Customer_Name_Local_Language__c = '0001';
        acc2.E_commerce_Customer_Label__c = '10';
        Database.insert(acc2);

        Account acc = new Account();
        acc.Name = 'Test Account003';
        acc.SAP_Customer_Code__c = '1234567890';
        acc.External_Key__c = '1234567890';
        acc.Sales_Region__c = 'Hisense USA';
        // acc.Payment_Term__c = paymentTerm.Id;
        acc.Guarantor_Country_Code__c = 'DZ';
        acc.Stor_Location__c = pockList.Id;
        acc.Payer__c = acc1.Id;
        acc.E_commerce_Customer_Label__c = '10';
        acc.Address__c = 'Test class Address class class class class class class class class class class class class class class class class';
        acc.Customer_Name_Local_Language__c = 'Customer_Name_Local_Language__cCustomer_Name_Local_Language__cCustomer_Name_Lo';
        // acc.Hisense_Entity__c = '8140';
        Database.insert(acc);
        
        Customer_Tax_category__c tax = new Customer_Tax_category__c();
        tax.Customer__c = acc.Id;
        Database.insert(tax);

        Customer_Extend__c ce = new Customer_Extend__c();
        ce.Customer__c = acc.id;
        ce.Hisense_Entity__c = '8300';
        Database.insert(ce);

        Customer_Extend_Tax_category__c teax = new Customer_Extend_Tax_category__c();
        teax.Customer_Extend__c = ce.Id;
        Database.insert(teax);

        TestDataUtility.createCustomSettings();
        Test.startTest();
    	String json = '{"FailReason":"","IsSuccess":"True","SAPCustomerCode":"0123012301","SFCodeFromSAP":"'+ ce.Name + '"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SyncCustomerInfoToSAP.postCustomerInfomationToSAP(ce.Id);
        Test.stopTest();
    }
}