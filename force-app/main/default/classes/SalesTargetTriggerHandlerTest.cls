@isTest
private class SalesTargetTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);

        Sales_Target_Branch_Company_Use__c s = new Sales_Target_Branch_Company_Use__c();
        s.Customer_Name_Import__c = acc1.SAP_Customer_Code__c;

        Database.insert(s);

        Test.stopTest();
    }
}