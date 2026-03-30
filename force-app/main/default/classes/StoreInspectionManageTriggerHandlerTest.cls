@isTest
public class StoreInspectionManageTriggerHandlerTest {
    @isTest
    static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Gridding__c testGridding = new Gridding__c();
        testGridding.Name = '中国重庆';
        testGridding.CurrencyIsoCode = 'USD';
        testGridding.Gridding_Level__c = 'A';
        Insert testGridding;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '测试门店';
        shop1.GiftGrid__c = testGridding.id;
        shop1.Sales_Region__c = 'Hisense South Africa';
        INSERT shop1;
        
        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
       	productTest.Product_Line__c = 'TV';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
        productTest.sales_region__c = 'Hisense South Africa';
       	Insert productTest;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  acc.id;
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.today();
        Insert testReport1;
        
        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = shop1.id;
        testRetailNumber.Product__c = productTest.id;
        testRetailNumber.Number__c = 1;
        testRetailNumber.Price__c = 1;
        testRetailNumber.TotalPrice__c = 1;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = acc.id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        Insert testRetailNumber;

        Test.startTest();
        Store_Inspection_Manage__c sim = new Store_Inspection_Manage__c();
        sim.Task_Type__c = '销售额';
        sim.Year__c = String.valueOf(Date.today().year());
        sim.Month__c = String.valueOf(Date.today().month());
        sim.Product_Line__c = 'TV';
        sim.Sales_Region__c = 'Hisense South Africa';
        insert sim;

        Store_Inspection_Manage__c sim1 = new Store_Inspection_Manage__c();
        sim1.Task_Type__c = '销售额';
        sim1.Year__c = String.valueOf(Date.today().year());
        sim1.Month__c = String.valueOf(Date.today().addMonths(1).month());
        sim1.Product_Line__c = 'TV';
        sim1.Sales_Region__c = 'Hisense South Africa';
        sim1.Store__c = shop1.id;
        insert sim1;
        Test.stopTest();
    }
}