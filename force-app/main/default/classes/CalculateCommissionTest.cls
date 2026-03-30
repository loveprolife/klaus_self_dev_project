@isTest
public with sharing class CalculateCommissionTest {

    public static Account customer;
    public static Shop__c store;
    public static Account brand;
    public static Promoter_Daily_Report__c report;
    public static Market__c market;
    public static Research__c research;

    
    public static User floorwalker;
    public static User promoter;
    public static CheckListScope__c checkScope;

    public static Product__c product;

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
        
    }

    public static List<SalesGoal__c> makeSalesGoalInfo() {

        makePromoterDailyReportData();

        product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

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

        Shop__c testShop = new Shop__c();
        testShop.name = '测试门店';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Promoter_Daily_Report__c testReport = new Promoter_Daily_Report__c();
        testReport.Customer__c =  customerTest.id;
        testReport.Shop__c = testShop.id;
        testReport.Report_Date__c = system.today();
        testReport.ResponsiblePerson__c = promoterRes.Id;
        //testReport.Name = '测试FootCountInquiryController用';
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

        SalesGoal__c dayGoal = new SalesGoal__c();
        dayGoal.RecordTypeId = dayRecordTypeId;
        dayGoal.Store__c = store.Id;
        dayGoal.TargetDay__c = date.newinstance(System.today().year(), System.today().month(), 1);
        // dayGoal.Product__c = product.Id;
        // dayGoal.ProductLine__c = 'Refrigerator';
        dayGoal.ResponsiblePerson__c = promoterRes.Id;
        dayGoal.Amounts__c = 80000;
        dayGoal.IsActive__c = true;
        goalList.add(dayGoal);


        SalesGoal__c monthGoal2 = new SalesGoal__c();
        monthGoal2.RecordTypeId = monthRecordTypeId;
        monthGoal2.Store__c = store.Id;
        monthGoal2.Year__c = System.today().year() + '';
        monthGoal2.Month__c = System.today().month() + '';
        monthGoal2.ResponsiblePerson__c = promoterRes.Id;
        monthGoal2.Amounts__c = 880000;
        monthGoal2.IsActive__c = true;
        goalList.add(monthGoal2);

        SalesGoal__c dayGoal2 = new SalesGoal__c();
        dayGoal2.RecordTypeId = dayRecordTypeId;
        dayGoal2.Store__c = store.Id;
        dayGoal2.TargetDay__c = date.newinstance(System.today().year(), System.today().month(), 1);
        dayGoal2.ResponsiblePerson__c = promoterRes.Id;
        dayGoal2.Amounts__c = 80000;
        dayGoal2.IsActive__c = true;
        goalList.add(dayGoal2);

        // SalesGoal__c errorPerson = new SalesGoal__c();
        // errorPerson.RecordTypeId = dayRecordTypeId;
        // errorPerson.TargetDay__c = date.newinstance(2023, 7, 13);
        // errorPerson.ResponsiblePerson__c = resPerson.Id;
        // errorPerson.Amounts__c = 80000;
        // errorPerson.IsActive__c = true;
        // goalList.add(errorPerson);
        
        insert goalList;
        
        return goalList;
    }
    
    @TestSetup
    static void makeData() {
        makeSalesGoalInfo();


        CommissionConfiguration__c cc = new CommissionConfiguration__c(
            Elements7__c=5,
            EndDate__c=Date.newInstance(2024,12, 1),
            HA__c=10,
            HighEnd__c=20,
            IsActive__c=true,
            Reporting__c=5,
            StartDate__c=Date.newInstance(2023,12, 1),
            TV__c=10,
            Total__c=50,
            RecordTypeId = Schema.SObjectType.CommissionConfiguration__c.getRecordTypeInfosByDeveloperName().get('HisenseIndonesia').getRecordTypeId()
        );
        insert cc;
        cc = new CommissionConfiguration__c(
            Elements7__c=5,
            EndDate__c=Date.newInstance(2024,12, 1),
            HA__c=10,
            HighEnd__c=20,
            IsActive__c=true,
            Reporting__c=5,
            ResponsiblePerson__c=[SELECT ID FROM Responsible_Person__c WHERE RecordType__c = '促销员' LIMIT 1].ID,
            StartDate__c=Date.newInstance(2023,12, 1),
            TV__c=0,
            Total__c=60,
            RecordTypeId = Schema.SObjectType.CommissionConfiguration__c.getRecordTypeInfosByDeveloperName().get('HisenseIndonesia').getRecordTypeId()
        );
        insert cc;
        cc.TV__c=10;
        cc.Total__c=50;
        update cc;
        ProductCommission__c pc = new ProductCommission__c(product__c = product.Id, Amount__c = 100);
        insert pc;


        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 600;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 3;
        sales1.ResponsiblePerson__c = [SELECT ID FROM Responsible_Person__c WHERE RecordType__c = '促销员'][0].Id;
        insert sales1;
    }
    
    @isTest
    static void test2() {
        Date d = System.today().adddays(1);
        SYstem.debug(d);
        LinkedListBatch.executeBatches(new LinkedListBatch[] {
            new GeneratePersonalCommissionBatch(d,null),
            new CalculateCommissionBatch(d,null)
        });
    }
    
    @isTest
    static void test3() {
        Date d = System.today().adddays(1);
        SYstem.debug(d);
        LinkedListBatch.executeBatches(new LinkedListBatch[] {
            new GenerateCommonCommissionBatch(d,null),
            new CalculateCommissionBatch(d,null)
        });
    }
}