/*
 * @Author: WFC
 * @Date: 2023-03-31 15:09:27
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-13 17:20:42
 * @Description:
 * @FilePath: \testuat\force-app\main\default\classes\CustomerExtendTriggerHandlerTest.cls
 */
@isTest
private class CustomerExtendTriggerHandlerTest{
    static testMethod void testMethod1(){
        Test.startTest();

        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8300';
        tcm.Country__c = 'US';
        insert tcm;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        TaxCountryMapping__c tcm2 = new TaxCountryMapping__c();
        tcm2.name = '8200';
        tcm2.Country__c = 'AU';
        insert tcm2;

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

        National_tax_category__c ntc2 = new National_tax_category__c();
        ntc2.National_code__c = 'AU';
        ntc2.sort__c = 2;
        ntc2.Tax_category__c = 'UTXJ';
        insert ntc2;

        National_tax_category__c ntc3 = new National_tax_category__c();
        ntc3.National_code__c = 'AU';
        ntc3.sort__c = 2;
        ntc3.Tax_category__c = '1';
        insert ntc3;

        Account acc = new Account(
            Name = 'Test sap1000000', 
            SAP_Customer_Code__c = 'sap1000000', 
            External_Key__c = 'sap1000000', 
            Sales_Region__c = 'salesRegion', 
            Approval_Status__c = 'Approved', 
            Hisense_Entity__c = '8300', 
            Hisense_Entity_Sales__c = '8300', 
            isGoFinApprove__c = 'fin_approved', 
            E_commerce_Customer_Label__c = '10', 
            Basic_Approval_Status__c = 'draft'
        );
        Database.insert (acc);

        Customer_Extend__c ce = new Customer_Extend__c();
        ce.Customer__c = acc.id;
        ce.Hisense_Entity_Sales__c = '8110';
        ce.Approval_Status__c = 'Draft';
        ce.Show_Company__c = true;
        ce.Show_Sales__c = true;
        Database.insert (ce);

        Customer_Extend__c ce1 = new Customer_Extend__c();
        ce1.Customer__c = acc.id;
        ce1.Hisense_Entity_Sales__c = '8300';
        ce1.Approval_Status__c = 'Approved';
        ce1.Extend_or_Not__c = true;
        ce1.Show_Company__c = true;
        ce1.Show_Sales__c = true;
        ce.Payer__c = acc.Id;
        ce.Receiver__c = acc.Id;
        Database.insert (ce1);

        Customer_Extend_Tax_category__c teax = new Customer_Extend_Tax_category__c();
        teax.Customer_Extend__c = ce.Id;
        Database.insert (teax);

        ce.Hisense_Entity_Sales__c = '8200';
        ce.Financial_Approval__c = true;
        Database.update (ce);

        ce.Show_Company__c = false;
        Database.update (ce);

        ce.Show_Company__c = true;
        ce.Show_Sales__c = false;
        Database.update (ce);

        Test.stopTest();
    }

}