/*
 * @Author: WFC
 * @Date: 2025-01-14 14:07:08
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-14 14:09:39
 * @Description: CustomeExtendAutoCreateInvocableMethod 测试类
 * @FilePath: \testuat\force-app\main\default\classes\CustomeExtendAutoCreateTest.cls
 */
@isTest
public class CustomeExtendAutoCreateTest{
    static testmethod void test(){
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

        CustomeExtendAutoCreateInvocableMethod.addCustomerExtend(new List<String>{ acc.Id });
    }

}