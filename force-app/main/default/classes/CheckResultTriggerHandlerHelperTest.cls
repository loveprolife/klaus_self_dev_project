@isTest
public class CheckResultTriggerHandlerHelperTest{
    @isTest
    static void testCheckResultTriggerHandlerHelper(){

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'testPromoterUser121382';
        promoter.alias = 'Promoter';
        promoter.email = 'Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id
                              FROM profile
                              WHERE Name LIKE '%Chile Promoter%'][0].Id;
        promoter.timezonesidkey = 'Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Chile';
        promoter.Department__c = 'Sales';
        insert promoter;

        User manager = new User();
        manager.Username = 'testManagerUser1213823@test004.com';
        manager.lastname = 'testManagerUser121382';
        manager.alias = 'manager';
        manager.email = 'manager@test.com';
        manager.emailencodingkey = 'UTF-8';
        manager.languagelocalekey = 'zh_CN';
        manager.LocaleSidKey = 'zh_CN';
        manager.IsActive = true;
        manager.ProfileId = [SELECT Id
                             FROM profile
                             WHERE Name LIKE '%Chile store manager%'][0].Id;
        manager.timezonesidkey = 'Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Chile';
        manager.Department__c = 'Sales';
        insert manager;

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.Description__c = 'CheckResultTriggerHandlerHelperTest';
        checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense Chile';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Booth and image';
        checkItem.MaximumScore__c = '5';
        checkItem.ResponsibleDepartment__c = 'Sales';
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        checkItem.Automatic_Generation_Ticket__c = true;
        insert checkItem;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        // Gridding
        Gridding__c gridding = new Gridding__c();
        gridding.Grid_Manager__c = manager.Id;
        Insert gridding;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        shop1.Grid__c = gridding.Id;
        Insert shop1;

        Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
        inspectionReport.Report_Date__c = System.today();
        inspectionReport.OwnerId = promoter.Id;
        inspectionReport.Store__c = shop1.Id;
        insert inspectionReport;

        Test.startTest();

        CheckResult__c checkResult = new CheckResult__c();
        checkResult.InspectorDailyReport__c = inspectionReport.Id;
        checkResult.CheckItem__c = checkItem.Id;
        checkResult.Status__c = 'Draft';
        checkResult.Max_Scores__c = 5;
        checkResult.Scores__c = 0;
        insert checkResult;

        checkResult.Status__c = 'Submitted';
        update checkResult;

        delete checkResult;

        Test.stopTest();
    }

    @isTest
    static void testCheckResultTriggerHandlerHelper1(){

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'testPromoterUser121382';
        promoter.alias = 'Promoter';
        promoter.email = 'Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id
                              FROM profile
                              WHERE Name LIKE '%Chile Promoter%'][0].Id;
        promoter.timezonesidkey = 'Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Chile';
        promoter.Department__c = 'Sales';
        insert promoter;

        User manager = new User();
        manager.Username = 'testManagerUser1213823@test004.com';
        manager.lastname = 'testManagerUser121382';
        manager.alias = 'manager';
        manager.email = 'manager@test.com';
        manager.emailencodingkey = 'UTF-8';
        manager.languagelocalekey = 'zh_CN';
        manager.LocaleSidKey = 'zh_CN';
        manager.IsActive = true;
        manager.ProfileId = [SELECT Id
                             FROM profile
                             WHERE Name LIKE '%Chile store manager%'][0].Id;
        manager.timezonesidkey = 'Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Australia';
        manager.Department__c = 'Sales';
        insert manager;

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.Description__c = 'CheckResultTriggerHandlerHelperTest';
        checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense Australia';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Booth and image';
        checkItem.Item_Type__c = 'Training';
        checkItem.Question_Type__c = 'Multiple Selection';
        checkItem.MaximumScore__c = '5';
        checkItem.ResponsibleDepartment__c = 'Sales';
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Australia').getRecordTypeId();
        checkItem.Automatic_Generation_Ticket__c = true;
        insert checkItem;

        CheckItem__c checkItem1 = new CheckItem__c();
        checkItem1.Description__c = 'CheckResultTriggerHandlerHelperTest';
        checkItem1.Active__c = true;
        checkItem1.Sales_Region__c = 'Hisense Australia';
        checkItem1.Product_Line__c = 'AC';
        checkItem1.Item_Type__c = 'Sample Display Check';
        checkItem1.Project__c = 'Booth and image';
        checkItem1.Question_Type__c = 'Picklist';
        checkItem1.MaximumScore__c = '5';
        checkItem1.ResponsibleDepartment__c = 'Sales';
        checkItem1.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Australia').getRecordTypeId();
        checkItem1.Automatic_Generation_Ticket__c = true;
        insert checkItem1;

        CheckItem__c checkItem2 = new CheckItem__c();
        checkItem2.Description__c = 'CheckResultTriggerHandlerHelperTest';
        checkItem2.Active__c = true;
        checkItem2.Sales_Region__c = 'Hisense Australia';
        checkItem2.Product_Line__c = 'WM';
        checkItem2.Item_Type__c = 'Sample Display Check';
        checkItem2.Project__c = 'Booth and image';
        checkItem2.Question_Type__c = 'Object';
        checkItem2.MaximumScore__c = '5';
        checkItem2.ResponsibleDepartment__c = 'Sales';
        checkItem2.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Australia').getRecordTypeId();
        checkItem2.Automatic_Generation_Ticket__c = true;
        insert checkItem2;

        CheckItem__c checkItem3 = new CheckItem__c();
        checkItem3.Description__c = 'CheckResultTriggerHandlerHelperTest';
        checkItem3.Active__c = true;
        checkItem3.Sales_Region__c = 'Hisense Australia';
        checkItem3.Product_Line__c = 'AC';
        checkItem3.Project__c = 'Booth and image';
        checkItem3.Item_Type__c = 'Training';
        checkItem3.Question_Type__c = 'Multiple Selection';
        checkItem3.MaximumScore__c = '5';
        checkItem3.ResponsibleDepartment__c = 'Sales';
        checkItem3.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Australia').getRecordTypeId();
        checkItem3.Automatic_Generation_Ticket__c = true;
        insert checkItem3;

        CheckItem__c checkItem4 = new CheckItem__c();
        checkItem4.Description__c = 'CheckResultTriggerHandlerHelperTest';
        checkItem4.Active__c = true;
        checkItem4.Sales_Region__c = 'Hisense Australia';
        checkItem4.Product_Line__c = 'Freezer';
        checkItem4.Project__c = 'Booth and image';
        checkItem4.Item_Type__c = 'Sample Display Check';
        checkItem4.Question_Type__c = 'Yes/No';
        checkItem4.MaximumScore__c = '5';
        checkItem4.ResponsibleDepartment__c = 'Sales';
        checkItem4.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Australia').getRecordTypeId();
        checkItem4.Automatic_Generation_Ticket__c = true;
        insert checkItem4;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        // Gridding
        Gridding__c gridding = new Gridding__c();
        gridding.Grid_Manager__c = manager.Id;
        Insert gridding;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        shop1.Grid__c = gridding.Id;
        Insert shop1;

        Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
        inspectionReport.Report_Date__c = System.today();
        inspectionReport.OwnerId = promoter.Id;
        inspectionReport.Store__c = shop1.Id;
        insert inspectionReport;

        Product__c product = new Product__c();
        product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        insert product;

        Test.startTest();

        CheckResult__c checkResult = new CheckResult__c();
        checkResult.InspectorDailyReport__c = inspectionReport.Id;
        checkResult.CheckItem__c = checkItem.Id;
        checkResult.Status__c = 'Draft';
        checkResult.Max_Scores__c = 5;
        checkResult.Scores__c = 0;
        checkResult.Response__c = 'TV;LASER';

        insert checkResult;

        CheckResult__c checkResult1 = new CheckResult__c();
        checkResult1.InspectorDailyReport__c = inspectionReport.Id;
        checkResult1.CheckItem__c = checkItem1.Id;
        checkResult1.Status__c = 'Draft';
        checkResult1.Max_Scores__c = 5;
        checkResult1.Scores__c = 0;
        checkResult1.Response__c = 'TV;LASER';

        insert checkResult1;

        CheckResult__c checkResult2 = new CheckResult__c();
        checkResult2.InspectorDailyReport__c = inspectionReport.Id;
        checkResult2.CheckItem__c = checkItem2.Id;
        checkResult2.Status__c = 'Draft';
        checkResult2.Max_Scores__c = 5;
        checkResult2.Scores__c = 0;
        checkResult2.Response__c = product.Id;

        insert checkResult2;

        CheckResult__c checkResult3 = new CheckResult__c();
        checkResult3.InspectorDailyReport__c = inspectionReport.Id;
        checkResult3.CheckItem__c = checkItem3.Id;
        checkResult3.Status__c = 'Draft';
        checkResult3.Max_Scores__c = 5;
        checkResult3.Scores__c = 0;
        checkResult3.Response__c = 'TV';
        insert checkResult3;

        CheckResult__c checkResult4 = new CheckResult__c();
        checkResult4.InspectorDailyReport__c = inspectionReport.Id;
        checkResult4.CheckItem__c = checkItem4.Id;
        checkResult4.Status__c = 'Draft';
        checkResult4.Max_Scores__c = 5;
        checkResult4.Scores__c = 0;
        checkResult4.Response__c = 'No';
        insert checkResult4;

        checkResult.Status__c = 'Submitted';
        checkResult1.Status__c = 'Submitted';
        checkResult2.Status__c = 'Submitted';
        checkResult3.Status__c = 'Submitted';
        checkResult4.Status__c = 'Submitted';

        List<CheckResult__c> updateList = new List<CheckResult__c>();
        updateList.add(checkResult);
        updateList.add(checkResult1);
        updateList.add(checkResult2);
        updateList.add(checkResult3);
        updateList.add(checkResult4);

        update updateList;

        // CheckResultTriggerHandlerHelper.generateUnplannedSample(new List<CheckResult__c>{ checkResult, checkResult1, checkResult2, checkResult3, checkResult4 });

        delete checkResult;

        Test.stopTest();
    }

}