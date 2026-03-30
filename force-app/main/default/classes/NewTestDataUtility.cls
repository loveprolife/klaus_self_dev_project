@isTest
public without sharing class NewTestDataUtility {
    
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

    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    
    public static string checkItemRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckItem__c' AND DeveloperName = 'South_Africa'].Id;
    public static string checkItemScopeRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckListScope__c' AND DeveloperName = 'South_Africa'].Id;
    
	public static void makePromoterDailyReportData(){
        
        customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        insert store;
        
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = date.newinstance(2024, 7, 13);
        insert report;

        market = new Market__c();
        market.Shop__c = store.Id;
        market.Report_Date__c = date.newinstance(2024, 7, 13);
        insert market;

        research = new Research__c();
        research.Shop__c = store.Id;
        research.Report_Date__c = date.newinstance(2024, 7, 13);
        insert research;
        
    }
    
    public static void makeBrandData() {
        Id brandRecordTypeId = [Select DeveloperName, SobjectType FROM RecordType where SobjectType= 'Account' and DeveloperName = 'Brand'].Id;
        brand = new Account();
        brand.RecordTypeId = brandRecordTypeId;
        brand.Name = 'Hair';
        insert brand;
    }
    
    public static void makeCheckListInfo() {
        customer = new Account();
        customer.Name = 'Wal-mart';
        customer.Sales_Region__c = 'Hisense South Africa';
        insert customer;
        
        store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        insert store;
        
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

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.RecordTypeId = checkItemRecordTypeId;
        checkItem.Sales_Region__c = 'Hisense South Africa';
        checkItem.Description__c = 'test';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Personnel';
        insert checkItem;

        checkScope = new CheckListScope__c();
        checkScope.CheckItem__c = checkItem.Id;
        checkScope.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope.Sales_Region__c = 'Hisense South Africa';
        checkScope.Store__c = store.Id;
        checkScope.Role__c = 'Floorwalker';
        insert checkScope;
    }

    public static List<SalesGoal__c> makeSalesGoalInfo() {

        makePromoterDailyReportData();

        product = new Product__c();
        product.Name = '65A65G';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Account customerTest = new Account();
        customerTest.Name = '客户';
        Insert customerTest;
        
        promoter = new User();
        promoter.Username = 'testPromoterUser12138@test004.com';
        promoter.lastname = 'testPromoterUser12138';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%促销员%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Country = 'ZA';
        insert promoter;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
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

        Responsible_Person__c promoterRes2 = new Responsible_Person__c();
        promoterRes2.Shop_Name__c = testShop.Id;
        promoterRes2.Principal__c = promoter.Id;
        promoterRes2.RecordType__c = '促销员';
        insert promoterRes2;
        
        Promoter_Daily_Report__c testReport = new Promoter_Daily_Report__c();
        testReport.Customer__c =  customerTest.id;
        testReport.Shop__c = testShop.id;
        //testReport.Name = '测试FootCountInquiryController用';
        Insert testReport;
        
        List<SalesGoal__c> goalList = new List<SalesGoal__c>();
        SalesGoal__c monthGoal = new SalesGoal__c();
        monthGoal.RecordTypeId = monthRecordTypeId;
        monthGoal.Store__c = store.Id;
        monthGoal.Year__c = System.today().year() + '';
        monthGoal.Month__c = System.today().month() + '';
        monthGoal.ProductLine__c = 'TV';
        monthGoal.ResponsiblePerson__c = promoterRes.Id;
        monthGoal.Amounts__c = 880000;
        monthGoal.IsActive__c = true;
        goalList.add(monthGoal);

        SalesGoal__c dayGoal = new SalesGoal__c();
        dayGoal.RecordTypeId = dayRecordTypeId;
        dayGoal.Store__c = testShop.Id;
        dayGoal.TargetDay__c = date.newinstance(System.today().year(), System.today().month(), 1);
        dayGoal.ProductLine__c = 'TV';
        dayGoal.ResponsiblePerson__c = promoterRes2.Id;
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
        dayGoal2.Store__c = testShop.Id;
        dayGoal2.TargetDay__c = date.newinstance(System.today().year(), System.today().month(), 1);
        dayGoal2.ResponsiblePerson__c = promoterRes2.Id;
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
}