@isTest
public class CreateFloorWalkerTrainingTest{
    @isTest
    static void test(){

        User promoter = new User();
        promoter.Username = 'testFloorwalkerUser1213823@test004.com';
        promoter.lastname = 'testFloorwalkerUser121382';
        promoter.alias = 'Hisense';
        promoter.email = 'Floorwalker@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id
                              FROM profile
                              WHERE Name LIKE '%Australia Floorwalker%'][0].Id;
        promoter.timezonesidkey = 'Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Australia';
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
                             WHERE Name LIKE '%Australia Store Manager%'][0].Id;
        manager.timezonesidkey = 'Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Australia';
        manager.Department__c = 'Sales';
        insert manager;

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.Description__c = 'How many staff were trained?';
        checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense Australia';
        checkItem.Item_Type__c = 'Training';
        checkItem.Question_Type__c = 'Integer';
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Australia').getRecordTypeId();
        insert checkItem;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense Australia';
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
        shop1.Sales_Region__c = 'Hisense Australia';
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
        checkResult.Response__c = '10';
        insert checkResult;

        inspectionReport.Status__c = 'Submitted';
        update inspectionReport;
        // Database.executeBatch(new CreateFloorWalkerTraining(), 200);
        // SchedulableContext sc;
        // CreateFloorWalkerTrainSchedule trainSchedule = new CreateFloorWalkerTrainSchedule();
        // trainSchedule.execute(sc);
        String cronExpression = '0 0 1 * * ?'; // 每天凌晨1点运行
        String jobName = 'CreateFloorWalkerTrainScheduleJobTest'; // 定时任务的名称
        CreateFloorWalkerTrainSchedule scheduler = new CreateFloorWalkerTrainSchedule();

        System.schedule(jobName, cronExpression, scheduler);
        Test.stopTest();
    }

}