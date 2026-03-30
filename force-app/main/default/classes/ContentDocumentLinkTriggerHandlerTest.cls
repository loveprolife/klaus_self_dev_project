@isTest
public with sharing class ContentDocumentLinkTriggerHandlerTest{
    @isTest
    static void testContentDocumentLinkTriggerHandler(){

        User user1 = new User();
        user1.Username = 'testContentDocumentLinkTriggerHandler@test004.com';
        user1.lastname = 'testContentDocumentLinkTriggerHandler';
        user1.alias = 'Promoter';
        user1.email = 'Promoter@test.com';
        user1.emailencodingkey = 'UTF-8';
        user1.languagelocalekey = 'zh_CN';
        user1.LocaleSidKey = 'zh_CN';
        user1.IsActive = true;
        user1.ProfileId = [SELECT Id
                           FROM profile
                           WHERE Name = 'System Administrator'][0].Id;
        user1.timezonesidkey = 'Asia/Shanghai';
        user1.Sales_Region__c = 'Hisense USA';
        user1.Department__c = 'Sales';
        insert user1;

        // 设置 mock
        String json = '{"code":0,"result":{"result":"未检测到异常"}}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));


        system.runAs(user1){
            Image_Ai_Interface__c iai = new Image_Ai_Interface__c();
            iai.Name = '电视黑屏检核';
            iai.Type__c = 'POST';
            iai.Url__c = 'https://open-apisix.hisense.com/hiai/gjyxkongyang?app_id=2iscpteb&app_key=fiufxcv0wwhxuwdtcjwvfxittzpuzp29';
            insert iai;

            Account acc = new Account();
            acc.Name = 'test';
            insert acc;

            Shop__c shop1 = new Shop__c();
            shop1.Account__c = acc.Id;
            shop1.Sales_Region__c = 'Hisense USA';
            shop1.Shop_Level__c = 'A';
            shop1.Name = 'Homeplus本石町店';
            insert shop1;

            Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
            ispTest.Inspection_Year__c = String.valueOf(System.today().year());
            ispTest.Inspection_Month__c = String.valueOf(System.today().month());
            ispTest.OwnerId = user1.Id;
            insert ispTest;

            Date date1 = Date.today();
            Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
            ist.Shop__c = shop1.Id;
            ist.ExternalId__c = acc.Id;
            ist.Status__c = '已到访';
            ist.Inspection_Plan__c = ispTest.id;
            ist.Inspection_Date__c = date1;
            ist.OwnerId = user1.Id;
            insert ist;

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            insert productTest;

            Sampling_Inspection__c si = new Sampling_Inspection__c();
            si.IsNew__c = true;
            si.ExternalID__c = acc.Id;
            si.Inspection_Shop_Task__c = ist.Id;
            si.Product__c = productTest.Id;
            insert si;

            Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
            inspectionReport.Report_Date__c = System.today();
            inspectionReport.OwnerId = user1.Id;
            inspectionReport.Store__c = shop1.Id;
            insert inspectionReport;

            CheckItem__c checkItem = new CheckItem__c();
            checkItem.Description__c = 'CheckResultTriggerHandlerHelperTest';
            checkItem.Active__c = true;
            checkItem.Sales_Region__c = 'Hisense USA';
            checkItem.Product_Line__c = 'TV';
            checkItem.Project__c = 'Booth and image';
            checkItem.MaximumScore__c = '5';
            checkItem.ResponsibleDepartment__c = 'Sales';
            checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('USA').getRecordTypeId();
            checkItem.Automatic_Generation_Ticket__c = true;
            checkItem.Has_Image_AI__c = true;
            checkItem.Image_AI__c = '电视黑屏检核';
            insert checkItem;

            CheckResult__c checkResult = new CheckResult__c();
            checkResult.InspectorDailyReport__c = inspectionReport.Id;
            checkResult.CheckItem__c = checkItem.Id;
            checkResult.Status__c = 'Draft';
            checkResult.Max_Scores__c = 5;
            checkResult.Scores__c = 0;
            insert checkResult;


            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins', 
                PathOnClient = 'Penguins.txt', 
                VersionData = Blob.valueOf('Test Content'), 
                IsMajorVersion = true
            );
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                               FROM ContentDocument];

            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = si.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;

            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = checkResult.id;
            cdl1.ContentDocumentId = documents[0].Id;
            cdl1.shareType = 'V';
            insert cdl1;
        }
    }
}