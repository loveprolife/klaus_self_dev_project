@isTest
private class CreditLimitApplicationTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();
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
        creditLimit.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit.Buyer_Country_Code__c = pickList.Id;
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        creditLimit.RecordTypeId = Schema.SObjectType.Credit_Limit_Application__c.getRecordTypeInfosByName().get('South Africa Local Insurance Credit Limit Application').getRecordTypeId();
        Database.insert(creditLimit);

        creditLimit.Credit_Limit_for_Application_USD__c = 5000001;
        creditLimit.Buyer_English_Address__c = '2';
        creditLimit.Approval_Status__c = 'Submitted';
        creditLimit.Approval_Date__c = Datetime.now().addDays(1);
        Database.update(creditLimit);

        creditLimit.Approval_Status__c = 'RR Approving';
        Database.update(creditLimit);

        Credit_Limit_Application__c creditLimit1 = new Credit_Limit_Application__c();
        creditLimit1.Customer__c = accId;
        creditLimit1.Payment_Method__c = '1';
        creditLimit1.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit1.Buyer_Country_Code__c = pickList.Id;
        creditLimit1.Buyer_English_Address__c = 'Test1';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit1.Credit_Guarantee_Issuing_Bank_SWIFT__c = '22222222';
        creditLimit1.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit1);

        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Test.startTest();
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
        creditLimit.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit.Buyer_Country_Code__c = pickList.Id;
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit);

        creditLimit.Buyer_English_Address__c = '2';
        creditLimit.Approval_Status__c = 'Submitted';
        creditLimit.Approval_Date__c = Datetime.now().addDays(1);
        Database.update(creditLimit);

        creditLimit.Approval_Status__c = 'RR Approving';
        Database.update(creditLimit);

        Credit_Limit_Application__c creditLimit1 = new Credit_Limit_Application__c();
        creditLimit1.Customer__c = accId;
        creditLimit1.Payment_Method__c = '1';
        creditLimit1.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit1.Buyer_Country_Code__c = pickList.Id;
        creditLimit1.Buyer_English_Address__c = 'Test1';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit1.Credit_Guarantee_Issuing_Bank_SWIFT__c = '22222222';
        creditLimit1.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit1);

        Test.stopTest();
    }

    static testMethod void testMethod3() {
       
        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Transaction_Settlement_Method_1_3year__c = 'LC';
        creditLimit.Transaction_Settlement_Method_2_3year__c = 'LC;ccccc';

        Test.startTest();
            CreditLimitApplicationTriggerHandler.validateSettlementMethodsForLC(creditLimit);
            CreditLimitApplicationTriggerHandler.validateSettlementMethodsForNonLC(creditLimit);
        Test.stopTest();
        
    }
}