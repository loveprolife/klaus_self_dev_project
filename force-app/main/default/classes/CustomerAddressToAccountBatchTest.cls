@isTest
public with sharing class CustomerAddressToAccountBatchTest{
    @isTest
    static void methodTest1(){
        TestDataUtility.createCustomSettings();

        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8110';
        tcm.Country__c = 'USA';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;


        Account acc1 = new Account();
        acc1.Name = 'Test Account002Test';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.Trader_Type__c = 'H002';
        acc1.Ecss_Flag__c = true;
        acc1.Ecss_Result__c = '123';
        insert (acc1);

        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.SAP_Customer_Code__c = '0001110001';
        ca.Email__c = '3333@qq.com';
        ca.Customer_Name_Local_Language_1__c = 'name-01';
        ca.Hisense_Entity__c = '8110';
        ca.Hisense_Entity_Sales__c = '8110';
        insert ca;

        Test.startTest();

        CustomerAddressToAccountBatch ss = new CustomerAddressToAccountBatch();
        Database.executeBatch(ss);

        CustomerAddressToAccountBatch ss1 = new CustomerAddressToAccountBatch('NoEntity');
        Database.executeBatch(ss1);

        CustomerAddressToAccountBatch ss2 = new CustomerAddressToAccountBatch(new List<String>{'0001110001'});
        Database.executeBatch(ss2);

        Test.stopTest();
    }

}