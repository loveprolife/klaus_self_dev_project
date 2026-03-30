@isTest
private with sharing class SalesGoalCustomerTargetSchedulableTest {

    public static string customerRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Customer_Target'].Id;
    
    static testMethod void test(){
        Test.startTest();

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        SalesGoal__c salesGoal = new SalesGoal__c();
        salesGoal.Customer__c = customer.Id;
        salesGoal.Name = '2024-01-18_Cencosud Retail S.A.';
        
        // target.Amounts__c = Decimal.valueOf(10);
        salesGoal.Amounts__c = 6000;
        salesGoal.CurrencyIsoCode = 'USD';
        salesGoal.TargetDay__c = Date.valueOf('2024-01-18');
        salesGoal.RecordTypeId = customerRecordTypeId;
        insert salesGoal;

        String CRON_EXP = '0 0 12 * * ?';
        SalesGoalCustomerTargetSchedulable schedulable = new SalesGoalCustomerTargetSchedulable();
        System.schedule('SalesGoalCustomerTargetSchedulableTest', CRON_EXP, schedulable);
        Test.stopTest();
    }


}