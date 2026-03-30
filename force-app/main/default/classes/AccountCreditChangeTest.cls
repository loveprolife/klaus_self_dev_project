@isTest
private class AccountCreditChangeTest {
    
    static testmethod void test() {
        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'US';
        insert tcm1;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        CreditGroup__c cg = new CreditGroup__c();
        cg.name = '8110';
        cg.Credit__c = '110';
        insert cg;

        Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.Hisense_Entity__c = '8110';
        acc1.Trader_Type__c = 'H002';
        insert(acc1);

        TestDataUtility.createCustomSettings();
        List<String> accIdList = new List<String>();
        accIdList.add(acc1.Id);
        Test.startTest();
    	String json = '{"FailReason":"","IsSuccess":"S"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        
        AccountCreditChange.AccountCreditChange(accIdList);

        String json1 = '{"FailReason":"","IsSuccess":"E"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        AccountCreditChange.AccountCreditChange(accIdList);

        Test.stopTest();
    }
 
}