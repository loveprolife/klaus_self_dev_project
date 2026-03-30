@isTest
public with sharing class InspectionPhotoNameScheduleTest {
    @istest
    public static void testMethod1(){
        CheckItem__c checkItem = new CheckItem__c();
		checkItem.Description__c = '111111';
		checkItem.Active__c = true;
        insert checkItem;

        CheckItem__c checkItem1 = new CheckItem__c();
		checkItem1.Description__c = '222222';
		checkItem1.Active__c = true;
        insert checkItem1;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense Argentina';
        Insert acc;

        User manager = new User();
        manager.Username = 'testManagerUser1213823@test004.com';
        manager.lastname = 'testManagerUser121382';
        manager.alias = 'manager';
        manager.email ='manager@test.com';
        manager.emailencodingkey = 'UTF-8';
        manager.languagelocalekey = 'zh_CN';
        manager.LocaleSidKey = 'zh_CN';
        manager.IsActive = true;
        manager.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Argentina store manager%'][0].Id;
        manager.timezonesidkey ='Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Argentina';
        manager.Department__c = 'Manager';
        insert manager;

        // Gridding
        Gridding__c gridding = new Gridding__c();
        gridding.Grid_Manager__c = manager.Id;
        Insert gridding;

        Channel_item__c channelItem  = new Channel_item__c();
        channelItem.Channel_Name__c = 'YAMADA';
        insert channelItem;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense Argentina';
        shop1.Grid__c = gridding.Id;
        shop1.Channel_item__c = channelItem.Id;
        Insert shop1;

        Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
        inspectionReport.Report_Date__c = System.today();
        inspectionReport.OwnerId = manager.Id;
        inspectionReport.Store__c = shop1.Id;
        insert inspectionReport;

        CheckResult__c checkResult = new CheckResult__c();
        checkResult.InspectorDailyReport__c = inspectionReport.Id;
        checkResult.CheckItem__c = checkItem.Id;
        checkResult.Status__c = 'Draft';
        checkResult.Max_Scores__c = 5;
        checkResult.Scores__c = 0;
        insert checkResult;

        CheckResult__c checkResult1 = new CheckResult__c();
        checkResult1.InspectorDailyReport__c = inspectionReport.Id;
        checkResult1.CheckItem__c = checkItem1.Id;
        checkResult1.Status__c = 'Draft';
        checkResult1.Max_Scores__c = 5;
        checkResult1.Scores__c = 0;
        insert checkResult1;

        Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest2.Name = 'NTC-24E-TV';
        productTest2.CurrencyIsoCode = 'USD';
        productTest2.Product_External_Id__c = 'NTC-24E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'Category';
        Insert productTest2;

        // Sampling_Detail__c testSD = new Sampling_Detail__c();
        // testSD.Shop__c = shop1.id;
        // testSD.Is_Add__c = '是';
        // testSD.Display_Status__c = '展出';
        // testSD.Product__c = productTest2.id;
        // testSD.Sampling_Standard__c = testSS.id;
        // Insert testSD;
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = manager.Id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Date.today().year() + '';
        ispTest.Inspection_Month__c = Date.today().month() + '';
        INSERT ispTest;

        // Daily_Inspection_Report__c testDIR2 = new Daily_Inspection_Report__c();
        // testDIR2.Report_Date__c = System.today();
        // testDIR2.Inspection_Shop_Plan__c = ispTest.id;
        // testDIR2.Store__c = shop1.id;
        // testDIR2.OwnerId = manager.Id;
        // testDIR2.Status__c = 'New';
        // testDIR2.NeedCheckIn__c = true;
        // Insert testDIR2;

        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest2.id;
        testSI1.Shop__c = shop1.id;
        // testSI1.Sample_Item__c = testSD.id;
        testSI1.Inspection_Report__c = inspectionReport.id;
        testSI1.ReRe__c = '测试rere1';
        testSI1.ExternalID__c = String.valueOf(inspectionReport.Report_Date__c) + '_' + inspectionReport.Store__c + '_' + productTest2.Id;
        Insert testSI1;

        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
        );
        insert contentVersion;  
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = checkResult.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = testSI1.id;
        cdl2.ContentDocumentId = documents[0].Id;
        cdl2.shareType = 'V';
        insert cdl2;

        InspectionPhotoNameSchedule scheduleClass = new InspectionPhotoNameSchedule();
        // String cronExpression = '0 0 2 * * ?'; // 每小时执行一次
        // String jobName = 'InspectionPhotoNameSchedule Job'; // 调度任务的名称
        // System.schedule(jobName, cronExpression, scheduleClass);

        // GetThaiSellOutInventorySchedulable cis1 = new GetThaiSellOutInventorySchedulable('GetThaiSellOutInventorySchedulable', '2024-05-01 08:00:00', 5000, 0, false, '', '');
        SchedulableContext sc1;
        scheduleClass.execute(sc1);
    }

}