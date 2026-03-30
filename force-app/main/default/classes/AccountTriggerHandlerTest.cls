@isTest
private class AccountTriggerHandlerTest {
    static testMethod void testMethod1() {
        
        TestDataUtility.createCustomSettings();

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

    	Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            Hisense_Entity__c = '8300',
            Hisense_Entity_Sales__c = '8300',
            isGoFinApprove__c = 'fin_approved',
            Basic_Approval_Status__c = 'draft',
            Trader_Type__c = 'H002',
            email__c = '333@qq.com'
        );
        Database.insert(acc1);
        
    	Account acc2 = new Account(
            Name = 'Test sap10000001',
            SAP_Customer_Code__c = 'sap1000001',
            External_Key__c = 'sap10000001',
            Sales_Region__c = 'salesRegion1',
            Approval_Status__c = 'Approved',
            Hisense_Entity__c = '8300',
            Hisense_Entity_Sales__c = '8300',
            isGoFinApprove__c = 'fin_approved',
            Basic_Approval_Status__c = 'draft',
            Address__c = '12313212321333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333'
        );
        Database.insert(acc2);

        Customer_Tax_category__c tax = new Customer_Tax_category__c();
        tax.Customer__c = acc1.Id;
        Database.insert(tax);

        PickList__c pickList = new PickList__c();
        pickList.Name = 'United States of America (USA)';
        pickList.Value__c = 'USA';
        pickList.ex_id__c = 'USA';
        pickList.belong_to_RR_Country__c = 'United States of America (USA)';
        pickList.RecordTypeId = Schema.SObjectType.PickList__c.getRecordTypeInfosByName().get('Master Data(RR Country)').getRecordTypeId();
        Database.insert(pickList);
        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Customer__c = acc1.Id;
        creditLimit.Payment_Method__c = '1';
        creditLimit.Approval_Status__c = 'Draft';
        creditLimit.Buyer_Country_Code__c = pickList.Id;
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        creditLimit.USA_State__c = 'AL';
        Database.insert(creditLimit);

        List<Customer_Product_Line__c> cpls = new List<Customer_Product_Line__c>();
        Customer_Product_Line__c cpl1 = new Customer_Product_Line__c();
        cpl1.Product_Line_Name__c = 'TV';
        cpl1.Customer__c = acc1.Id;
        cpl1.Management_Customer__c = acc1.Id;
        cpl1.Classification__c = 'Agency Customer';//
        cpl1.Development_Stage__c = 'Undeveloped';
        cpl1.Rank__c = 'Strategy Customer';
        cpls.add(cpl1);

        Customer_Product_Line__c cpl2 = new Customer_Product_Line__c();
        cpl2.Product_Line_Name__c = 'WM';
        cpl2.Customer__c = acc1.Id;
        cpl2.Management_Customer__c = acc1.Id;
        cpl2.Classification__c = 'OEM Customer';//OEM Customer
        cpl2.Development_Stage__c = 'Undeveloped';
        
        cpls.add(cpl2);

        Customer_Product_Line__c cpl3 = new Customer_Product_Line__c();
        cpl3.Product_Line_Name__c = 'Freezer';
        cpl3.Customer__c = acc1.Id;
        cpl3.Management_Customer__c = acc1.Id;
        cpl3.Classification__c = 'Customer of Oversea Company';
        cpl3.Development_Stage__c = 'Undeveloped';
        cpl3.Rank__c = 'Strategy Customer';
        cpls.add(cpl3);
        Database.insert(cpls);

        String plids = cpl1.id+';'+cpl2.id+';'+cpl3.id; 
        Score_Sheet__c ss = new Score_Sheet__c();
        ss.Customer__c = acc1.id;
        ss.PL_ID_List__c = plids;
        insert ss;

        String plids1 = cpl1.id+';'+cpl2.id+';'+cpl3.id; 
        Score_Sheet__c ss1 = new Score_Sheet__c();
        ss1.Customer__c = acc1.id;
        ss1.PL_ID_List__c = plids1;
        insert ss1;

        Test.startTest();

        acc1.Approval_Status__c = 'Submitted';
        acc1.Basic_Approval_Status__c = 'Submitted';
        acc1.Headquarters_Approval_Status__c = 'Submitted';
        acc1.Hisense_Entity__c = '8110';
        acc1.Japan_Unlock_Tag__c = System.now();
        Database.update(acc1);
        
        acc1.Basic_Approval_Status__c = 'Approved';
        acc1.Approval_Status__c = 'Draft';
        acc1.Japan_Unlock_Tag__c = System.now();
        Database.update(acc1);

        acc1.Approval_Status__c = 'Approved';
        Database.update(acc1);

        acc1.Active_Flag__c = true;
        Database.update(acc1);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();

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

        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            Hisense_Entity__c = '8300',
            isGoFinApprove__c = 'fin_approved',
            Basic_Approval_Status__c = 'draft'
        );
        insert(acc1);

        Test.startTest();
        delete(acc1);
        AccountTriggerHandler.checkTest();
        Test.stopTest();

    }
}