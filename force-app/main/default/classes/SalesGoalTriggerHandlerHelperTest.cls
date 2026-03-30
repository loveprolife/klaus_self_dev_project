@isTest
public class SalesGoalTriggerHandlerHelperTest {

    public static string monthRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Month'].Id;
    public static string dayRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Day'].Id;
    public static string customerRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Customer_Target'].Id;
    
    //@isTest
    static void testSalesGoalTriggerHandlerHelper() {
    
        List<SalesGoal__c> goalList = NewTestDataUtility.makeSalesGoalInfo();

        Test.startTest();
        
        // goalList[0].Month__c = '5';
        // goalList[1].TargetDay__c = date.newinstance(2024, 5, 13);
        // update goalList[0];
        // update goalList[1];
        
        Product__c product2 = new Product__c();
        product2.Name = '88A66G';
        insert product2;

        Promoter_Daily_Report__c report = NewTestDataUtility.report;
        report.OwnerId = NewTestDataUtility.promoter.Id;
        update report;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = NewTestDataUtility.report.Id;
        sales1.Product__c = NewTestDataUtility.product.Id;
        sales1.Shop__c = NewTestDataUtility.store.Id;
        sales1.Price__c = 600;
        sales1.Status__c = 'new';
        sales1.Number__c = 3;
        insert sales1;
        
        sales1.Price__c = 900;
        
        update sales1;
        
        sales1.Product__c = product2.Id;
        sales1.Price__c = 800;
        sales1.Status__c = 'Submitted';
        update sales1;
        
        delete sales1;
		
        SalesGoalTriggerHandlerHelper.sharingRelatedOperations(goalList, 'delete');

        SalesVSTargetController.getInitData();
        
        Test.stopTest();
        
    }


    @isTest
    static void testSalesGoalTriggerHandlerHelper2() {
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Chile';

        Shop__c store2 = new Shop__c();
        store2.Name = 'Hi Fi Corporation NEWCASTLE22';
        store2.Account__c = customer.Id;
        store2.Sales_Region__c = 'Hisense Chile';
        insert new List<Shop__c>{store, store2};

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'promoter';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Chile Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Chile';
        insert promoter;

        Promoter_Attendance_Rule__c attendanceRule = new Promoter_Attendance_Rule__c();
        attendanceRule.Start_time__c = Time.newInstance(9,0,0,0);
        attendanceRule.End_time__c = Time.newInstance(18,0,0,0);
        attendanceRule.Time_buffer__c = 15;
        insert attendanceRule;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
        promoterRes.Promoter_Attendance_Rule__c = attendanceRule.Id;
        insert promoterRes;

        Responsible_Person__c promoterRes2 = new Responsible_Person__c();
        promoterRes2.Shop_Name__c = store2.Id;
        promoterRes2.Principal__c = promoter.Id;
        promoterRes2.RecordType__c = '促销员';
        promoterRes2.Promoter_Attendance_Rule__c = attendanceRule.Id;
        new List<Responsible_Person__c>{promoterRes, promoterRes2};

        List<SalesGoal__c> goalList = new List<SalesGoal__c>();
        SalesGoal__c monthGoal = new SalesGoal__c();
        monthGoal.RecordTypeId = monthRecordTypeId;
        monthGoal.Store__c = store.Id;
        monthGoal.Year__c = String.valueOf(Date.today().year() + 1);
        monthGoal.Month__c = String.valueOf(Date.today().addMonths(3).month());
        monthGoal.ProductLine__c = 'TV';
        monthGoal.ResponsiblePerson__c = promoterRes.Id;
        monthGoal.Amounts__c = 880000;
        // monthGoal.IsActive__c = true;
        insert monthGoal;
    }

    @isTest
    static void testSalesGoalTriggerHandlerHelper3() {
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Chile';

        Shop__c store2 = new Shop__c();
        store2.Name = 'Hi Fi Corporation NEWCASTLE22';
        store2.Account__c = customer.Id;
        store2.Sales_Region__c = 'Hisense Chile';
        insert new List<Shop__c>{store, store2};

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'promoter';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Chile Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Chile';
        insert promoter;

        Promoter_Attendance_Rule__c attendanceRule = new Promoter_Attendance_Rule__c();
        attendanceRule.Start_time__c = Time.newInstance(9,0,0,0);
        attendanceRule.End_time__c = Time.newInstance(18,0,0,0);
        attendanceRule.Time_buffer__c = 15;
        insert attendanceRule;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
        promoterRes.Promoter_Attendance_Rule__c = attendanceRule.Id;
        insert promoterRes;

        Responsible_Person__c promoterRes2 = new Responsible_Person__c();
        promoterRes2.Shop_Name__c = store2.Id;
        promoterRes2.Principal__c = promoter.Id;
        promoterRes2.RecordType__c = '促销员';
        promoterRes2.Promoter_Attendance_Rule__c = attendanceRule.Id;
        new List<Responsible_Person__c>{promoterRes, promoterRes2};

        SalesGoal__c dayGoal = new SalesGoal__c();
        dayGoal.RecordTypeId = dayRecordTypeId;
        dayGoal.Store__c = store2.Id;
        dayGoal.TargetDay__c = Date.today().addDays(3);
        dayGoal.ProductLine__c = 'TV';
        dayGoal.ResponsiblePerson__c = promoterRes2.Id;
        dayGoal.Amounts__c = 80000;
        // dayGoal.IsActive__c = true;
        insert dayGoal;

        dayGoal.TargetDay__c = Date.today().addDays(2);
        update dayGoal;
        
    }

    @isTest
    static void testSalesGoalTriggerHandlerHelper4() {
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Chile';

        Shop__c store2 = new Shop__c();
        store2.Name = 'Hi Fi Corporation NEWCASTLE22';
        store2.Account__c = customer.Id;
        store2.Sales_Region__c = 'Hisense Chile';
        insert new List<Shop__c>{store, store2};

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'promoter';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Chile Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Chile';
        insert promoter;

        Promoter_Attendance_Rule__c attendanceRule = new Promoter_Attendance_Rule__c();
        attendanceRule.Start_time__c = Time.newInstance(9,0,0,0);
        attendanceRule.End_time__c = Time.newInstance(18,0,0,0);
        attendanceRule.Time_buffer__c = 15;
        insert attendanceRule;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
        promoterRes.Promoter_Attendance_Rule__c = attendanceRule.Id;
        insert promoterRes;

        Responsible_Person__c promoterRes2 = new Responsible_Person__c();
        promoterRes2.Shop_Name__c = store2.Id;
        promoterRes2.Principal__c = promoter.Id;
        promoterRes2.RecordType__c = '促销员';
        promoterRes2.Promoter_Attendance_Rule__c = attendanceRule.Id;
        new List<Responsible_Person__c>{promoterRes, promoterRes2};

        SalesGoal__c customerGoal = new SalesGoal__c();
        customerGoal.RecordTypeId = customerRecordTypeId;
        customerGoal.Customer__c = customer.Id;
        customerGoal.TargetDay__c = Date.today().addDays(3);
        customerGoal.Amounts__c = 80000;
        // dayGoal.IsActive__c = true;
        insert customerGoal;

        customerGoal.Amounts__c = 600;
        update customerGoal;

        customerGoal.IsActive__c = false;
        customerGoal.TargetDay__c = Date.today().addDays(2);
        update customerGoal;
        
    }

}