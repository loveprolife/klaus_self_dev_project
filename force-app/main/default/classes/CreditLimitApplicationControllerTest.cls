@isTest
private class CreditLimitApplicationControllerTest {
    static testMethod void testMethod1() {
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
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
        Database.insert(creditLimit);
        CreditLimitApplicationButtonController.cloneCreaditLimit(String.valueOf(creditLimit.Id));
    }
}