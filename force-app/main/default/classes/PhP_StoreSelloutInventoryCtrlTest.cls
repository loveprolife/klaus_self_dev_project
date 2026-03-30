/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
public class PhP_StoreSelloutInventoryCtrlTest {

    public static Account customer;
    public static Shop__c store;
    public static Account brand;
    public static Promoter_Daily_Report__c report;
    public static Promoter_Daily_Report__c report1;
    public static Market__c market;
    public static Research__c research;

    
    public static User floorwalker;
    public static User promoter;
    public static CheckListScope__c checkScope;

    public static Product__c product;

    public static Product__c product2;

    public static Product__c product3;

    public static string monthRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Month'].Id;
    public static string dayRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Day'].Id;
    
    public static string checkItemRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckItem__c' AND DeveloperName = 'South_Africa'].Id;
    public static string checkItemScopeRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckListScope__c' AND DeveloperName = 'South_Africa'].Id;
    public static string productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
	public static void makePromoterDailyReportData(){
        
        customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.sales_region__c = 'Hisense Indonesia';
        insert store;
        
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today();
        insert report;

        report1 = new Promoter_Daily_Report__c();
        report1.Shop__c = store.Id;
        report1.Report_Date__c = system.today().addDays(-1);
        insert report1;

        product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        product2 = new Product__c();
        product2.Name = '65A75G';
        product2.Product_Line__c = 'WM';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;

        product3 = new Product__c();
        product3.Name = '65A85G';
        product3.Product_Line__c = 'TV';
        product3.RecordTypeId = productRecordTypeId;
        insert product3;

        Account customerTest = new Account();
        customerTest.Name = '客户';
        Insert customerTest;
        
        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        promoter = new User();
        promoter.Username = 'testPromoterUser12138@test004.com';
        promoter.lastname = 'testPromoterUser12138';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name = 'Indonesia Promoter'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Country = 'ID';
        promoter.sales_region__c = 'Hisense Indonesia';
        insert promoter;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
        promoterRes.Promoter_Attendance_Rule__c = par.Id;
        insert promoterRes;

        floorwalker = new User();
        floorwalker.Username = 'testUser12138@test004.com';
        floorwalker.lastname = 'testUser12138';
        floorwalker.alias = 'test';
        floorwalker.email ='testUser@test.com';
        floorwalker.emailencodingkey = 'UTF-8';
        floorwalker.languagelocalekey = 'zh_CN';
        floorwalker.LocaleSidKey = 'zh_CN';
        floorwalker.IsActive = true;
        floorwalker.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%巡店员%'][0].Id;
        floorwalker.timezonesidkey ='Asia/Shanghai';
        floorwalker.Country = 'ZA';
        insert floorwalker;
        
        Responsible_Person__c resPerson = new Responsible_Person__c();
        resPerson.Shop_Name__c = store.Id;
        resPerson.Principal__c = floorwalker.Id;
        resPerson.RecordType__c = '巡店员';
        insert resPerson;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c testShop = new Shop__c();
        testShop.City__c = '重庆';
        testShop.Shop_Level__c = 'A';
        testShop.Grid__c = grid.id;
        testShop.Shop_Code_Text__c = '90999';
        testShop.Shop_Center_Location__Latitude__s = 29.4545;
        testShop.Shop_Center_Location__Longitude__s = 106.509;
        Insert testShop;
        
        Promoter_Daily_Report__c testReport = new Promoter_Daily_Report__c();
        testReport.Customer__c =  customerTest.id;
        testReport.Shop__c = testShop.id;
        testReport.Report_Date__c = system.today();
        testReport.ResponsiblePerson__c = promoterRes.Id;
        Insert testReport;
        
        List<SalesGoal__c> goalList = new List<SalesGoal__c>();
        SalesGoal__c monthGoal = new SalesGoal__c();
        monthGoal.RecordTypeId = monthRecordTypeId;
        monthGoal.Store__c = store.Id;
        monthGoal.Year__c = System.today().year() + '';
        monthGoal.Month__c = System.today().month() + '';
        monthGoal.ResponsiblePerson__c = promoterRes.Id;
        monthGoal.Amounts__c = 880000;
        monthGoal.IsActive__c = true;
        goalList.add(monthGoal);

        // SalesGoal__c dayGoal = new SalesGoal__c();
        // dayGoal.RecordTypeId = dayRecordTypeId;
        // dayGoal.Store__c = store.Id;
        // dayGoal.TargetDay__c = date.newinstance(System.today().year(), System.today().month(), 1);
        // // dayGoal.Product__c = product.Id;
        // // dayGoal.ProductLine__c = 'Refrigerator';
        // dayGoal.ResponsiblePerson__c = promoterRes.Id;
        // dayGoal.Amounts__c = 80000;
        // dayGoal.IsActive__c = true;
        // goalList.add(dayGoal);


        // SalesGoal__c monthGoal2 = new SalesGoal__c();
        // monthGoal2.RecordTypeId = monthRecordTypeId;
        // monthGoal2.Store__c = store.Id;
        // monthGoal2.Year__c = System.today().year() + '';
        // monthGoal2.Month__c = System.today().month() + '';
        // monthGoal2.ResponsiblePerson__c = promoterRes.Id;
        // monthGoal2.Amounts__c = 880000;
        // monthGoal2.IsActive__c = true;
        // goalList.add(monthGoal2);

        // SalesGoal__c dayGoal2 = new SalesGoal__c();
        // dayGoal2.RecordTypeId = dayRecordTypeId;
        // dayGoal2.Store__c = store.Id;
        // dayGoal2.TargetDay__c = date.newinstance(System.today().year(), System.today().month(), 1);
        // dayGoal2.ResponsiblePerson__c = promoterRes.Id;
        // dayGoal2.Amounts__c = 80000;
        // dayGoal2.IsActive__c = true;
        // goalList.add(dayGoal2);
        
        // insert goalList;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 600;
        sales1.ProductLine__c = 'TV';
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 1;
        sales1.TotalPrice__c = sales1.Price__c * sales1.Number__c;
        // sales1.ResponsiblePerson__c = [SELECT ID FROM Responsible_Person__c WHERE RecordType__c = '促销员'][0].Id;
        sales1.ResponsiblePerson__c = promoterRes.Id;
        insert sales1;

        Retail_Number__c sales2 = new Retail_Number__c();
        sales2.PromoterDailyReport__c = report1.Id;
        sales2.Product__c = product.Id;
        sales2.Shop__c = store.Id;
        sales2.Price__c = 600;
        sales1.ProductLine__c = 'TV';
        sales2.Status__c = 'Submitted';
        // sales2.Stock_In_Transit__c = 2;
        sales2.Number__c = 1;
        sales1.ResponsiblePerson__c = promoterRes.Id;
        insert sales2;

        Promotional_Stock__c stock1 = new Promotional_Stock__c();
        stock1.Promoter_Daily_Report__c = report.Id;
        stock1.Product_Model__c = product.Id;
        stock1.Store_Code__c = store.Id;
        stock1.Quantities__c = 600;

        stock1.SaveDate__c = report.Report_Date__c;
        stock1.Status__c = 'Submitted';
        insert stock1;
        
        Promotional_Stock__c stock2 = new Promotional_Stock__c();
        stock2.Promoter_Daily_Report__c = report.Id;
        stock2.Product_Model__c = product2.Id;
        stock2.Store_Code__c = store.Id;
        stock2.Quantities__c = 600;

        stock2.SaveDate__c = report.Report_Date__c;
        stock2.Status__c = 'Submitted';
        insert stock2;

        Promotional_Stock__c stock3 = new Promotional_Stock__c();
        stock3.Promoter_Daily_Report__c = report.Id;
        stock3.Product_Model__c = product3.Id;
        stock3.Store_Code__c = store.Id;
        stock3.Quantities__c = 600;
        stock3.SaveDate__c = report.Report_Date__c;
        stock3.Status__c = 'Submitted';
        insert stock3;
        
    }

    @isTest
    static void testMethod1(){
        makePromoterDailyReportData();
        Test.startTest();
        Philippines_StoreSelloutInventoryCtrl.initData(store.Id);
        Test.stopTest();
    }

    @isTest
    static void testMethod2(){
        makePromoterDailyReportData();
        Test.startTest();
        Philippines_StoreSelloutInventoryCtrl.initDetail(store.Id);
        Test.stopTest();
    }
    // @isTest
    // static void testMethod3(){
    //     makePromoterDailyReportData();
    //     Test.startTest();
    //     Philippines_StoreSelloutInventoryCtrl.testClassMethod();
    //     Test.stopTest();
    // }

}