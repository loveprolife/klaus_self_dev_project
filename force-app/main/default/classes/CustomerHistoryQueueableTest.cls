@isTest
public with sharing class CustomerHistoryQueueableTest{
    static testMethod void testMethod1(){
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8500';
        tcm.Country__c = 'US';
        insert tcm;

        Account acc = new Account(
            Name = 'Test Account001', 
            SAP_Customer_Code__c = '1234567890', 
            External_Key__c = '1234567890', 
            Sales_Region__c = 'Hisense USA', 
            Hisense_Entity__c = '8500', 
            Approval_Status__c = 'Approved',
            Type = 'Management', 
            Active_Flag__c = false,
            Latest_Version__c = '1111'
        );
        insert acc;

        Customer_Extend__c ce1 = new Customer_Extend__c();
        ce1.Customer__c = acc.id;
        ce1.Show_Company__c = true;
        ce1.Show_Sales__c = false;
        insert ce1;

        Customer_Extend__c ce2 = new Customer_Extend__c();
        ce2.Customer__c = acc.id;
        ce2.Show_Company__c = false;
        ce2.Show_Sales__c = true;
        insert ce2;

        Customer_Banks__c cb = new Customer_Banks__c();
        cb.Customer__c = acc.id;
        cb.Bank_Country__c = 'US';
        cb.Bank_Account__c = '123';
        cb.Approval_Status__c = 'Draft';
        cb.Bank_name_local_language__c = '123';
        insert cb;

        Customer_Extend_Tax_category__c teax = new Customer_Extend_Tax_category__c();
        teax.Customer_Extend__c = ce1.Id;
        insert teax;

        String jobID = System.enqueueJob(new CustomerHistoryQueueable(acc.Id));
    }

}