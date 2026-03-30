@isTest
private class CustomerInvoiceSchedulableTest {
    static testMethod void testMethod1() {
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8500';
        tcm.Country__c = 'US';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        Account acc1 = new Account(
            Name = 'Test Account001',
            SAP_Customer_Code__c = '1234567890',
            External_Key__c = '1234567890',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            Active_Flag__c = false
        );
        Database.insert(acc1);
        Account acc2 = new Account(
            Name = 'Test Account002',
            SAP_Customer_Code__c = '12345678902',
            External_Key__c = '12345678902',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            Active_Flag__c = false,
            ParentId = acc1.id
        );
        Database.insert(acc2);
        Account acc3 = new Account(
            Name = 'Test Account003',
            SAP_Customer_Code__c = '12345678903',
            External_Key__c = '12345678903',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            Active_Flag__c = true
        );
        Database.insert(acc3);
        Account acc4 = new Account(
            Name = 'Test Account004',
            SAP_Customer_Code__c = '12345678904',
            External_Key__c = '12345678904',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            Active_Flag__c = true,
            ParentId = acc1.id
        );
        Database.insert(acc4);
        Account acc5 = new Account(
            Name = 'Test Account005',
            SAP_Customer_Code__c = '12345678905',
            External_Key__c = '12345678905',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            Active_Flag__c = true
        );
        Database.insert(acc5);
        Account acc6 = new Account(
            Name = 'Test Account006',
            SAP_Customer_Code__c = '12345678906',
            External_Key__c = '12345678906',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            Active_Flag__c = true
        );
        Database.insert(acc6);

        Invoice__c inv = new Invoice__c();
        inv.Customer__c = acc1.id;
        inv.Invoice_Date__c = Date.today();
        inv.Total_Amount_Inc_Tax__c = 100;
        inv.CurrencyIsoCode = 'USD';
        insert inv;
        Invoice__c inv1 = new Invoice__c();
        inv1.Customer__c = acc1.id;
        inv1.Invoice_Date__c = Date.today();
        inv1.Total_Amount_Inc_Tax__c = 99000000;
        inv1.CurrencyIsoCode = 'USD';
        insert inv1;
        Invoice__c inv2 = new Invoice__c();
        inv2.Customer__c = acc3.id;
        inv2.Invoice_Date__c = Date.today();
        inv2.Total_Amount_Inc_Tax__c = 99000000;
        inv2.CurrencyIsoCode = 'USD';
        insert inv2;
        Invoice__c inv3 = new Invoice__c();
        inv3.Customer__c = acc4.id;
        inv3.Invoice_Date__c = Date.today();
        inv3.Total_Amount_Inc_Tax__c = 10;
        inv3.CurrencyIsoCode = 'USD';
        insert inv3;
        Invoice__c inv4 = new Invoice__c();
        inv4.Customer__c = acc5.id;
        inv4.Invoice_Date__c = Date.today();
        inv4.Total_Amount_Inc_Tax__c = 10;
        inv4.CurrencyIsoCode = 'USD';
        insert inv4;

        Account acc7 = new Account(
            Name = 'Test Account007',
            SAP_Customer_Code__c = '12345678907',
            External_Key__c = '12345678907',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management'
        );
        Database.insert(acc7);
        Account acc8 = new Account(
            Name = 'Test Account008',
            SAP_Customer_Code__c = '12345678908',
            External_Key__c = '12345678908',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            ParentId = acc7.id
        );
        Database.insert(acc8);
        Account acc9 = new Account(
            Name = 'Test Account009',
            SAP_Customer_Code__c = '12345678909',
            External_Key__c = '12345678909',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8500',
            Type = 'Management',
            ParentId = acc7.id
        );
        Database.insert(acc9);
        Invoice__c inv11 = new Invoice__c();
        inv11.Customer__c = acc8.id;
        inv11.Invoice_Date__c = Date.today();
        inv11.Total_Amount_Inc_Tax__c = 10;
        inv11.CurrencyIsoCode = 'USD';
        insert inv11;
        Invoice__c inv12 = new Invoice__c();
        inv12.Customer__c = acc9.id;
        inv12.Invoice_Date__c = Date.today();
        inv12.Total_Amount_Inc_Tax__c = 9999999;
        inv12.CurrencyIsoCode = 'USD';
        insert inv12;


        CustomerInvoiceSchedulable cis = new CustomerInvoiceSchedulable('8500,8510');
        SchedulableContext sc;
        cis.execute(sc);
    }

}