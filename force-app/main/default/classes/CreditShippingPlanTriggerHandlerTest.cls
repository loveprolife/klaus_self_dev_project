@isTest
private class CreditShippingPlanTriggerHandlerTest {
    static testMethod void testMethod1() {
        
        //ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Account acc1 = new Account(
            Name = 'TestAccount 1',
            SAP_Customer_Code__c = '0000504263',
            External_Key__c = '0000504263',
            Sales_Region__c = 'Hisense USA',
            Trader_Type__c = 'H002'
        );
        Database.insert(acc1); 

        ID accId = acc1.Id;
        PickList__c pickList = new PickList__c();
        pickList.Name = 'United States of America (USA)';
        pickList.Value__c = 'USA';
        pickList.ex_id__c = 'USA';
        pickList.belong_to_RR_Country__c = 'United States of America (USA)';
        pickList.RecordTypeId = Schema.SObjectType.PickList__c.getRecordTypeInfosByName().get('Master Data(RR Country)').getRecordTypeId();
        Database.insert(pickList);
        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Customer__c = accId;
        creditLimit.Payment_Method__c = '1';
        creditLimit.Approval_Status__c = 'Draft'; 
        creditLimit.Buyer_Country_Code__c = pickList.Id;
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        creditLimit.USA_State__c = 'AL';
        creditLimit.RecordTypeId = Schema.SObjectType.Credit_Limit_Application__c.getRecordTypeInfosByName().get('South Africa Local Insurance Credit Limit Application').getRecordTypeId();
        Database.insert(creditLimit);

        Test.startTest();
        Credit_Shipping_Plan__c csp = new Credit_Shipping_Plan__c();
        csp.Credit_Limit_Application__c = creditLimit.Id;
        csp.Shipping_Month__c = '2026-05';
        csp.Shipping_Amount__c = 111;
        insert csp;
        delete csp;

        Test.stopTest();
    }
}