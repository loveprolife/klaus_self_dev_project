@isTest
public class ReportConfigTriggerHandlerHelperTest {
    public static String chileMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('ChileMonthlyReport').getRecordTypeId();
    public static String ChileWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('ChileWeeklyReport').getRecordTypeId();
    public static String IndonesiaMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('IndonesiaMonthlyReport').getRecordTypeId();
    public static String IndonesiaWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('IndonesiaWeeklyReport').getRecordTypeId();
    public static String SouthAfricaMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('SouthAfricaMonthlyReport').getRecordTypeId();
    public static String SouthAfricaWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('SouthAfricaWeeklyReport').getRecordTypeId();
   
    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();

    @testSetup
    static void setup() {
        ReportConfigurationInformation__c weeklyConfigOfChile = new ReportConfigurationInformation__c();
        weeklyConfigOfChile.RecordTypeId = ChileWeekly;
        weeklyConfigOfChile.FirstDayOfWeeklyReport__c = '1';
        weeklyConfigOfChile.Units__c = 'newIntelligence;marketInsight';
        weeklyConfigOfChile.Active__c = true;
        insert weeklyConfigOfChile;

        ReportConfigurationInformation__c monthlyConfigOfChile = new ReportConfigurationInformation__c();
        monthlyConfigOfChile.RecordTypeId = chileMonthly;
        weeklyConfigOfChile.Units__c = 'inHouseShare;shelfShare';
        monthlyConfigOfChile.Active__c = true;
        insert monthlyConfigOfChile;

        ReportConfigurationInformation__c weeklyConfigOfIndonesia = new ReportConfigurationInformation__c();
        weeklyConfigOfIndonesia.RecordTypeId = IndonesiaWeekly;
        weeklyConfigOfIndonesia.FirstDayOfWeeklyReport__c = '1';
        weeklyConfigOfIndonesia.Units__c = 'newIntelligence;storeView;marketInsight';
        weeklyConfigOfIndonesia.Active__c = true;
        insert weeklyConfigOfIndonesia;

        ReportConfigurationInformation__c monthlyConfigOfIndonesia = new ReportConfigurationInformation__c();
        monthlyConfigOfIndonesia.RecordTypeId = IndonesiaMonthly;
        monthlyConfigOfIndonesia.Units__c = 'inHouseShare;shelfShare';
        monthlyConfigOfIndonesia.Active__c = true;
        insert monthlyConfigOfIndonesia;

        ReportConfigurationInformation__c weeklyConfigOfSouthAfrica = new ReportConfigurationInformation__c();
        weeklyConfigOfSouthAfrica.RecordTypeId = SouthAfricaWeekly;
        weeklyConfigOfSouthAfrica.FirstDayOfWeeklyReport__c = '1';
        weeklyConfigOfSouthAfrica.Units__c = 'newIntelligence;storeView;marketInsight;promoCourt';
        weeklyConfigOfSouthAfrica.Active__c = true;
        insert weeklyConfigOfSouthAfrica;

        ReportConfigurationInformation__c monthlyConfigOfSouthAfrica = new ReportConfigurationInformation__c();
        monthlyConfigOfSouthAfrica.RecordTypeId = SouthAfricaMonthly;
        monthlyConfigOfSouthAfrica.Units__c = 'inHouseShare;shelfShare;consumerTraitResearch;footCountInquiry';
        monthlyConfigOfSouthAfrica.Active__c = true;
        insert monthlyConfigOfSouthAfrica;
    }

    @isTest
    static void testReportController() {
        Account customerOfChile = new Account();
        customerOfChile.Name = 'Wal-mart-Chile';
        insert customerOfChile;
        
        Shop__c storeOfChile = new Shop__c();
        storeOfChile.Name = 'Hi Fi Corporation NEWCASTLE Chile';
        storeOfChile.Account__c = customerOfChile.Id;
        storeOfChile.Sales_Region__c = 'Hisense Chile';
        insert storeOfChile;

        ReportConfigurationInformation__c weeklyConfigOfCustomer = new ReportConfigurationInformation__c();
        weeklyConfigOfCustomer.RecordTypeId = ChileWeekly;
        weeklyConfigOfCustomer.Customer__c = customerOfChile.Id;
        weeklyConfigOfCustomer.FirstDayOfWeeklyReport__c = '2';
        weeklyConfigOfCustomer.Units__c = 'newIntelligence;marketInsight';
        weeklyConfigOfCustomer.Active__c = true;
        insert weeklyConfigOfCustomer;

        ReportConfigurationInformation__c monthlyConfigOfCustomer = new ReportConfigurationInformation__c();
        monthlyConfigOfCustomer.RecordTypeId = chileMonthly;
        monthlyConfigOfCustomer.Customer__c = customerOfChile.Id;
        monthlyConfigOfCustomer.Units__c = 'inHouseShare;shelfShare';
        monthlyConfigOfCustomer.Active__c = true;
        insert monthlyConfigOfCustomer;

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Chile';
        insert store;

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

        Responsible_Person__c promoterResOfChile = new Responsible_Person__c();
        promoterResOfChile.Shop_Name__c = storeOfChile.Id;
        promoterResOfChile.Principal__c = promoter.Id;
        promoterResOfChile.RecordType__c = '促销员';
        promoterResOfChile.Promoter_Attendance_Rule__c = attendanceRule.Id;
        insert promoterResOfChile;

        Brand__c brandHisense = new Brand__c();
        brandHisense.Name = 'Hisense';
        insert brandHisense;

        Brand__c brandMedia = new Brand__c();
        brandMedia.Name = 'Media';
        insert brandMedia;

        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.sales_region__c = 'Hisense Chile';
        product.RecordTypeId = productRecordTypeId;
        insert product;


        Test.startTest();

        Market__c weeklyReport = new Market__c();
        Research__c monthlyReport = new Research__c();
       
        System.runAs(promoter) {

            // test WeeklyReportController
            ConResponse initResp = WeeklyReportController.getInitData('', '', '');
            Map<String, Object> initRespData = (Map<String, Object>)initResp.data;
            weeklyReport = (Market__c)initRespData.get('weeklyReport');

            String weekDateInfo = weeklyReport.Weeks__c;
            String recordJson = JSON.serialize(weeklyReport);
            ConResponse createResp = WeeklyReportController.createReport(recordJson);
            Map<String, Object> createRespData = (Map<String, Object>)createResp.data;
            weeklyReport = (Market__c)createRespData.get('weeklyReport');
            
            WeeklyReportController.saveData(recordJson);
            WeeklyReportController.getInitData('', weekDateInfo, store.Id);
            WeeklyReportController.getInitData('', weekDateInfo, storeOfChile.Id);

            WeeklyReportController.isPhaseIIIUser(weeklyReport.Id);

            // test IntelligenceController
            IntelligenceController.getInitData(weeklyReport.Id);
            List<Map<String, Object>> srdList = new List<Map<String, Object>>();

            Map<String, Object> srdItem1Map = new Map<String, Object>();
            Shop_Retail_Detail__c srdItem1 = new Shop_Retail_Detail__c();
            srdItem1.Brands__c = brandHisense.Id;
            srdItem1.Product__c = product.Id;
            srdItem1.Price__c = 8900;
            srdItem1Map.put('intelligenceDataInfo', srdItem1);
            srdItem1Map.put('filesInfo', new List<String>{'intelligence_1_1'});
            srdList.add(srdItem1Map);

            Map<String, Object> srdItem2Map = new Map<String, Object>();
            Shop_Retail_Detail__c srdItem2 = new Shop_Retail_Detail__c();
            srdItem2.Brands__c = brandMedia.Id;
            srdItem2.ProductInformation__c = 'test';
            srdItem2.Price__c = 8700;
            srdItem2Map.put('intelligenceDataInfo', srdItem2);
            srdItem2Map.put('filesInfo', new List<String>{'intelligence_1_2'});
            srdList.add(srdItem2Map);

            String intelligenceJson = '[' + JSON.serialize(srdList) + ']';
            IntelligenceController.saveRecord(weeklyReport.Id, intelligenceJson, '');
            IntelligenceController.saveRecord(weeklyReport.Id, '[]', '');

            // test MonthlyReportController
            ConResponse monthInitResp = MonthlyReportController.getInitData('', '', '');
            Map<String, Object> monthInitRespData = (Map<String, Object>)monthInitResp.data;
            monthlyReport = (Research__c)monthInitRespData.get('monthlyReport');

            String monthDateInfo = monthlyReport.Months__c;
            String monthRecordJson = JSON.serialize(monthlyReport);
            ConResponse monthCreateResp = MonthlyReportController.createReport(monthRecordJson);
            Map<String, Object> monthCreateRespData = (Map<String, Object>)monthCreateResp.data;
            monthlyReport = (Research__c)monthCreateRespData.get('monthlyReport');
            
            MonthlyReportController.saveData(monthRecordJson);
            MonthlyReportController.getInitData('', monthDateInfo, store.Id);
            MonthlyReportController.getInitData('', monthDateInfo, storeOfChile.Id);

            // test PromoterRemindersController2
            PromoterRemindersController2.getInitData();
        }

        Test.stopTest();
    }

    @isTest
    static void testReportConfigurationTriggerHandlerHelper() {

        Test.startTest();

        Account customerOfChile = new Account();
        customerOfChile.Name = 'Wal-mart-Chile';
        insert customerOfChile;

        ReportConfigurationInformation__c weeklyConfigOfCustomer = new ReportConfigurationInformation__c();
        weeklyConfigOfCustomer.RecordTypeId = ChileWeekly;
        weeklyConfigOfCustomer.Customer__c = customerOfChile.Id;
        weeklyConfigOfCustomer.FirstDayOfWeeklyReport__c = '2';
        weeklyConfigOfCustomer.Units__c = 'newIntelligence;marketInsight';
        weeklyConfigOfCustomer.Active__c = true;
        insert weeklyConfigOfCustomer;
        weeklyConfigOfCustomer.FirstDayOfWeeklyReport__c = '4';
        update weeklyConfigOfCustomer;

        ReportConfigurationInformation__c monthlyConfigOfCustomer = new ReportConfigurationInformation__c();
        monthlyConfigOfCustomer.RecordTypeId = chileMonthly;
        monthlyConfigOfCustomer.Customer__c = customerOfChile.Id;
        monthlyConfigOfCustomer.Units__c = 'inHouseShare;shelfShare';
        insert monthlyConfigOfCustomer;
        monthlyConfigOfCustomer.Active__c = true;
        update monthlyConfigOfCustomer;

        Test.stopTest();
    } 

    @isTest
    static void testCreateReportConfigurationItemBatch() {
        Test.startTest();

        CreateReportConfigItemBatchSchedulable createReportConfigItem = new CreateReportConfigItemBatchSchedulable();
        SchedulableContext sc;
        createReportConfigItem.execute(sc);

        Test.stopTest();
    }

    @isTest
    static void testWeeklyMonthlReportReminder() {
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Chile';
        insert store;

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

        Test.startTest();
        WeeklyMonthlReportReminderSchedulable reportReminder = new WeeklyMonthlReportReminderSchedulable('Hisense Chile');
        SchedulableContext sc;
        reportReminder.execute(sc);
        Test.stopTest();
    }
}