@isTest
public with sharing class SalesVSTargetControllerTest {
 
    public static User promoter;
    public static User manager;
    public static String monthRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Month'].Id;
    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    public static UserRole managerRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Indonesia_Training_Manager'];
    public static UserRole promoterRole = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Indonesia_Promoter_1'];

    // @TestSetup
    // static void makeData(){
    //     List<SalesGoal__c> goalList = NewTestDataUtility.makeSalesGoalInfo();
    // }

    @isTest
    static void testSalesVSTargetController() {
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        promoter = new User();
        promoter.Username = 'testPromoterUser121382@test004.com';
        promoter.lastname = 'testPromoterUser121382';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Indonesia';
        insert promoter;

        manager = new User();
        manager.Username = 'testManagerUser121382@test004.com';
        manager.lastname = 'testManagerUser121382';
        manager.alias = 'manager';
        manager.email ='manager@test.com';
        manager.emailencodingkey = 'UTF-8';
        manager.languagelocalekey = 'zh_CN';
        manager.LocaleSidKey = 'zh_CN';
        manager.IsActive = true;
        manager.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Indonesia store manager%'][0].Id;
        manager.timezonesidkey ='Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Indonesia';
        insert manager;

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

        SalesGoal__c monthGoal = new SalesGoal__c();
        monthGoal.RecordTypeId = monthRecordTypeId;
        monthGoal.Store__c = store.Id;
        monthGoal.Year__c = String.valueOf(date.today().year());
        monthGoal.Month__c = String.valueOf(date.today().month());
        monthGoal.ResponsiblePerson__c = promoterRes.Id;
        monthGoal.Amounts__c = 880000;
        monthGoal.IsActive__c = true;
        insert monthGoal;

        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Test.startTest();

        updateRoles();

        // System.runAs(promoter) {
            Map<String, Object> reportMap = new Map<String, Object>();
            reportMap.put('Shop__c', store.Id);
            reportMap.put('OwnerId', promoter.Id);
            reportMap.put('Report_Date__c', date.today());
            reportMap.put('Status__c', 'New');
            String reportJson = Json.serialize(reportMap);

            // Map<String, Object> salesMap = new Map<String, Object>();
            // salesMap.put('Price__c', 600);
            // salesMap.put('Number__c', 3);
            // String salesJson = Json.serialize(new List<Map<String, Object>>{salesMap});

            Map<String, Object> mso = (Map<String, Object>)NewPromoterDailyReportActionController.createData(reportJson).data;
            Promoter_Daily_Report__c report = (Promoter_Daily_Report__c)mso.get('record');

            reportMap.put('Id', report.Id);
            reportJson = Json.serialize(reportMap);

            Retail_Number__c testRetailNumber = new Retail_Number__c();
            testRetailNumber.Shop__c = store.id;
            testRetailNumber.Product__c = product.id;
            testRetailNumber.Number__c = 2;
            testRetailNumber.Price__c = 3600;
            testRetailNumber.CurrencyIsoCode = 'USD';
            testRetailNumber.PromoterDailyReport__c = report.Id;
            insert testRetailNumber;

            List<String> retailList = new List<String>();
		    retailList.add('test001');
            retailList.add('test002');
            NewPromoterDailyReportActionController.InputDataInfo retailNumberData = new NewPromoterDailyReportActionController.InputDataInfo();
            retailNumberData.dailySaleDataInfo = testRetailNumber;
            retailNumberData.filesInfo = retailList;
            List<NewPromoterDailyReportActionController.InputDataInfo> retailNumberList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
            retailNumberList.add(retailNumberData);
            String salesJson = Json.serialize(retailNumberList);

            // NewPromoterDailyReportActionController.createData(reportJson);
            // NewPromoterDailyReportActionController.saveDailySalesData(reportJson, salesJson, '');
            system.debug('reportJson：' + reportJson);
            system.debug('salesJson：' + salesJson);
            NewPromoterDailyReportActionController.saveData(reportJson, salesJson, '', '', '', true, '', '', '', '');

            System.debug('testSalesVSTargetController：' + [SELECT Id, Name,Status__c FROM Promoter_Daily_Report__c]);
            System.debug('testSalesVSTargetController：' + [SELECT Id, Name, CreatedById, Status__c, SameMonth__c FROM Retail_Number__c]);
            SalesVSTargetController.getInitData();
        // }

        Test.stopTest();
        
    }

    @future
    public static void updateRoles() {
        promoter.UserRoleId = promoterRole.Id;
        update promoter;

        manager.UserRoleId = managerRole.Id;
        update manager;
    }
}