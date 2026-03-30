@isTest
private class CustomerAddressTriggerHandlerTest {
    
    static testmethod void test() {

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

        Test.startTest();

        Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.Hisense_Entity__c = '8110';
        acc1.Trader_Type__c = 'H002';
        insert(acc1);

        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc1.Id;
        ca.Email__c = '3333@qq.com';
        ca.Hisense_Entity_Sales__c = '8300';
        ca.Approval_Status__c = 'Draft';
        insert ca;

        ca.Approval_Status__c = 'Approved';
        ca.Hisense_Entity_Sales__c = '8110';
        update ca;


        delete ca;

        Test.stopTest();
    }

    static testmethod void test1() {

        Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.Hisense_Entity__c = '8110';
        acc1.Trader_Type__c = 'H002';
        insert(acc1);

        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc1.Id;
        insert ca;

        Test.startTest();
        Customer_Email__c ce = new Customer_Email__c();
        ce.Email__c = '123@qq.com';
        ce.Customer_Address__c = ca.Id;
        insert ce;

        Customer_Email__c ce1 = new Customer_Email__c();
        ce1.Email__c = '123456@qq.com';
        ce1.Customer_Address__c = ca.Id;
        insert ce1;

        ce1.No__c  = 1;
        update ce1;

        ce1.No__c = 2;
        update ce1;

        delete ce1;

        Test.stopTest();

        
    }
 
}