@isTest
private class SAPCodeGenerationLogSchedulableTest {

    static testMethod void testMethod1() {

        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
        u.username = 'HisenseSSORegHandlerTest@salesforce.com';
        u.email = 'megan.xing@hisense.com';
        u.lastName = 'HisenseSSORegHandlerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.HisenseSSOName__c = 'testId';
        insert u;

        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8300';
        tcm.Country__c = 'US';
        insert tcm;


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
            Hisense_Entity__c = '8200', 
            Hisense_Entity_Sales__c = '8200', 
            isGoFinApprove__c = 'fin_approved', 
            E_commerce_Customer_Label__c = '10', 
            Basic_Approval_Status__c = 'draft',
            SAP_Code_Generation_Time__c = System.now().addHours(-5)
        );
        Database.insert (acc);

        Customer_Extend__c ce = new Customer_Extend__c();
        ce.Customer__c = acc.id;
        ce.Hisense_Entity_Sales__c = '8200';
        ce.Hisense_Entity__c = '8200';
        ce.Approval_Status__c = 'Draft';
        ce.Show_Company__c = true;
        ce.Show_Sales__c = true;
        Database.insert (ce);

        SAPCodeGenerationLogSchedulable cis = new SAPCodeGenerationLogSchedulable('111');
        SchedulableContext sc;
        cis.execute(sc);

    }
   
}