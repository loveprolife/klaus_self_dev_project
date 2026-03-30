@isTest
private with sharing class CustomerTargetTriggerHandlerHelperTest {

    public static string customerRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Customer_Target'].Id;
    
    static testMethod void test(){
        
        Test.startTest();


        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        SalesGoal__c salesGoal = new SalesGoal__c();
        salesGoal.Customer__c = acc.Id;
        salesGoal.Name = '2024-01-18_Cencosud Retail S.A.';
        
        // target.Amounts__c = Decimal.valueOf(10);
        salesGoal.Amounts__c = 6000;
        salesGoal.CurrencyIsoCode = 'USD';
        salesGoal.TargetDay__c = Date.valueOf('2024-01-18');
        salesGoal.RecordTypeId = customerRecordTypeId;
        insert salesGoal;

        SalesGoal__c salesGoal1 = new SalesGoal__c();
        salesGoal1.Customer__c = acc.Id;
        
        // target.Amounts__c = Decimal.valueOf(10);
        salesGoal1.Amounts__c = 6000;
        salesGoal1.CurrencyIsoCode = 'USD';
        salesGoal1.TargetDay__c = Date.valueOf('2024-01-31');
        salesGoal1.RecordTypeId = customerRecordTypeId;
        insert salesGoal1;

        Shop__c shop = new Shop__c();
        shop.Account__c = salesGoal.Customer__c;
        insert shop;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        insert report;

        Retail_Number__c dailySales = new Retail_Number__c();
        dailySales.Shop__c = shop.Id;
        dailySales.TotalPrice__c = 60;
        dailySales.PromoterDailyReport__c = report.Id;
        insert dailySales;

        CustomerTargetTriggerHandlerHelper.computeAmount(salesGoal);
        CustomerTargetTriggerHandlerHelper.computeAmount(salesGoal1);

        
        Test.stopTest();
        
    }
}