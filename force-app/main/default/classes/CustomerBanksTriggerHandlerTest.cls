@isTest
private class CustomerBanksTriggerHandlerTest {
    static testMethod void testMethod1() {

        MDG_Bank__c mb = new MDG_Bank__c();
        mb.External_Key__c = '123';
        mb.BANKS__c = 'US';
        mb.BANKA__c = '123';
        mb.BANKL__c = '123';
        mb.ZQSBM__c = '123';
        insert mb;

        Test.startTest();

        Account acc = new Account(
          Name = 'Test Account001',
          SAP_Customer_Code__c = '1234567890',
          External_Key__c = '1234567890',
          Sales_Region__c = 'Hisense USA',
          Type = 'Management',
          Guarantor_Country_Code__c = 'US'
        );
   
        Database.insert(acc);

        Customer_Banks__c ce = new Customer_Banks__c();
        ce.Customer__c = acc.id;
        ce.Bank_Country__c = 'US';
        ce.Bank_Account__c = '123';
        ce.Approval_Status__c = 'Draft';
        ce.Bank_name_local_language__c = '123';
        ce.MDG_Bank__c = mb.Id;
        Database.insert(ce);

        ce.Bank_Account__c = '1234';
        ce.Approval_Status__c = 'Approved';
        Database.update(ce);

        Test.stopTest();

    }
}