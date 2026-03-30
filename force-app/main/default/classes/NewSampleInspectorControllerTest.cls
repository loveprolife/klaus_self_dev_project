@isTest
public class NewSampleInspectorControllerTest{
    @isTest
    static void testMethod1(){
        NewSampleInspectorController.gabige();
        String profileName = '促销员';
        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :'South Africa Store Manager'].get(0).Id;
        User user1 = new User(
            alias = '促销员', 
            email = 'TestCX@noemail.com', 

            emailencodingkey = 'UTF-8', 
            lastname = 'TestCX', 
            languagelocalekey = 'en_US', 
            Sales_Region__c = 'Hisense South Africa', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'South Africa', 
            Country__c = 'South Africa', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testCX120231@noemail.com'
        );
        INSERT user1;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90986';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Name = 'CX签出测试店';
        shop2.Shop_Code_Text__c = '90988';
        shop2.Grid__c = grid.id;
        shop2.Shop_Center_Location__Latitude__s = 59.4545;
        shop2.Shop_Center_Location__Longitude__s = 86.509;
        INSERT shop2;

        Shop__c shop3 = new Shop__c();
        shop3.Account__c = acc.Id;
        shop3.Shop_Level__c = 'B';
        shop3.Name = '测试店333';
        shop3.Shop_Code_Text__c = '90998';
        shop3.Grid__c = grid.id;
        INSERT shop3;

        Shop__c shop4 = new Shop__c();
        shop4.Account__c = acc.Id;
        shop4.Shop_Level__c = 'A';
        shop4.Name = '测试店444';
        shop4.Shop_Code_Text__c = '90997';
        shop4.Grid__c = grid.id;
        INSERT shop4;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        productTest.Name = 'NTC-22E-TV';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;

        Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        productTest2.Name = 'NTC-24E-TV';
        productTest2.CurrencyIsoCode = 'USD';
        productTest2.Product_External_Id__c = 'NTC-24E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'Category';
        Insert productTest2;

        Product__c productTest3 = new Product__c();
        productTest3.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        productTest3.Name = 'NTC-333E-TV';
        productTest3.CurrencyIsoCode = 'USD';
        productTest3.Product_External_Id__c = 'NTC-333E-TV';
        productTest3.Series__c = 'hisense tv';
        productTest3.Category__c = 'Category';
        Insert productTest3;

        Product__c productTest4 = new Product__c();
        productTest4.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        productTest4.Name = 'NTC-444E-TV';
        productTest4.CurrencyIsoCode = 'USD';
        productTest4.Product_External_Id__c = 'NTC-444E-TV';
        productTest4.Series__c = 'hisense tv';
        productTest4.Category__c = 'Category';
        Insert productTest4;

        Sample_inspector__c testDIR = new Sample_inspector__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        Insert testDIR;

        Sample_inspector__c testDIR2 = new Sample_inspector__c();
        testDIR2.Report_Date__c = System.today();
        testDIR2.Store__c = shop2.id;
        testDIR2.OwnerId = user1.id;
        testDIR2.Status__c = 'New';
        Insert testDIR2;

        Sample_inspector__c testDIR3 = new Sample_inspector__c();
        testDIR3.Report_Date__c = System.today();
        testDIR3.Store__c = shop3.id;
        testDIR3.OwnerId = user1.id;
        testDIR3.Status__c = 'New';
        Insert testDIR3;

        Sample_inspector__c testDIR4 = new Sample_inspector__c();
        testDIR4.Report_Date__c = System.today();
        testDIR4.Store__c = shop4.id;
        testDIR4.OwnerId = user1.id;
        testDIR4.Status__c = 'New';
        Insert testDIR4;

        Sample_inspector__c testDIR5 = new Sample_inspector__c();
        testDIR5.Report_Date__c = System.today();
        testDIR5.Store__c = shop1.id;
        testDIR5.OwnerId = user1.id;
        testDIR5.Status__c = 'New';
        Insert testDIR5;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        Task testTask1 = new Task();
        testTask1.Status = 'Open';
        testTask1.OwnerId = user1.id;
        testTask1.WhatId = testDIR.id;
        testTask1.Description = '测试CR的task';
        testTask1.Subject = 'Send Letter';
        testTask1.Priority = 'Low';

        Task testTask2 = new Task();
        testTask2.Status = 'Closed';
        testTask2.OwnerId = user1.id;
        testTask2.WhatId = testDIR.id;
        testTask2.Description = '测试CR的task';
        testTask2.Subject = 'Send Letter';
        testTask2.Priority = 'Low';

        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest2.id;
        testSS.OwnerId = user1.id;
        testSS.Is_Add_ByReport__c = true;
        Insert testSS;

        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop1.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest2.id;
        testSD.Sampling_Standard__c = testSS.id;

        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest2.id;
        testSI1.Shop__c = shop2.id;
        testSI1.Sample_Item__c = testSD.id;
        testSI1.ReRe__c = '测试rere1';
        testSI1.ExternalID__c = String.valueOf(testDIR2.Report_Date__c) + '_' + testDIR2.Store__c + '_' + productTest2.Id;

        Sampling_Inspection__c testSI2 = new Sampling_Inspection__c();
        testSI2.Inspection_Date__c = System.today();
        testSI2.Placement_Status__c = '展出';
        testSI2.Unplanned_Sample__c = 'Yes';
        testSI2.Product__c = productTest2.id;
        testSI2.Shop__c = shop1.id;
        testSI2.Sample_Item__c = testSD.id;
        testSI2.ReRe__c = '测试rere2';
        testSI2.ExternalID__c = String.valueOf(testDIR.Report_Date__c) + '_' + testDIR.Store__c + '_' + productTest2.Id;

        Sampling_Inspection__c testSI3 = new Sampling_Inspection__c();
        testSI3.Inspection_Date__c = System.today();
        testSI3.Placement_Status__c = '展出';
        testSI3.Unplanned_Sample__c = 'Yes';
        testSI3.Product__c = productTest3.id;
        testSI3.Shop__c = shop3.id;
        testSI3.Sample_Item__c = testSD.id;
        testSI3.ReRe__c = '测试rere3';
        testSI3.ExternalID__c = String.valueOf(testDIR3.Report_Date__c) + '_' + testDIR3.Store__c + '_' + productTest3.Id;

        Sampling_Inspection__c testSI4 = new Sampling_Inspection__c();
        testSI4.Inspection_Date__c = System.today();
        testSI4.Placement_Status__c = '展出';
        testSI4.Unplanned_Sample__c = 'Yes';
        testSI4.Product__c = productTest4.id;
        testSI4.Shop__c = shop4.id;
        testSI4.Sample_Item__c = testSD.id;
        testSI4.ReRe__c = '测试rere3';
        testSI4.ExternalID__c = String.valueOf(testDIR4.Report_Date__c) + '_' + testDIR4.Store__c + '_' + productTest4.Id;

        String VersionStr = 'sdsadddddddddd';
        ContentVersion testCV = new ContentVersion();
        testCV.VersionData = Blob.valueOf(JSON.serialize(VersionStr));
        testCV.Title = 'title';
        testCV.PathOnClient = 'C:/home/user/picture/image';
        Insert testCV;

        String currentLatStr = '86.587556';
        String currentLongStr = '29.567932';

        String recordJson1 = JSON.serialize(testDIR);
        String recordJsonUpdate = JSON.serialize(testDIR5);
        String recordJsonUpdate2 = JSON.serialize(testDIR4);

        String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';

        List<Sampling_Inspection__c> samplingInspectionList = new List<Sampling_Inspection__c>();
        samplingInspectionList.add(testSI1);
        String samplingInspectionJson = JSon.serialize(samplingInspectionList);

        List<Sampling_Inspection__c> samplingInspectionList2 = new List<Sampling_Inspection__c>();
        samplingInspectionList2.add(testSI2);
        String samplingInspectionJson2 = JSon.serialize(samplingInspectionList2);

        List<Task> taskListopen = new List<Task>();
        taskListopen.add(testTask1);
        String ticketOpenJson = JSon.serialize(taskListopen);

        List<Task> taskListClose = new List<Task>();
        taskListClose.add(testTask2);
        String taskListCloseJson = JSon.serialize(taskListClose);

        map<String, Object> ticketOpenFilesMap = new map<String, Object>();
        ticketOpenFilesMap.put(testDIR.id, 'file');
        String ticketOpenFilesMapJson = JSON.serialize(ticketOpenFilesMap);


        boolean isSubmit = true;


        String recordDateStr = String.valueOf(testSI1.Inspection_Date__c);

        List<Sampling_Inspection__c> inList = new List<Sampling_Inspection__c>();
        inList.add(testSI3);
        String inListJson = JSON.serialize(inList);

        List<Sampling_Inspection__c> outList = new List<Sampling_Inspection__c>();
        outList.add(testSI4);
        String outListJson = JSON.serialize(outList);

        String testDIRJson = JSON.serialize(testDIR);
        String testDIRJson2 = JSON.serialize(testDIR3);

        Test.startTest();
        NewSampleInspectorController.getInitData(testDIR.id, currentLatStr, currentLongStr, '');
        //NewSampleInspectorController.getInitData(null, currentLatStr, null, '');
        NewSampleInspectorController.refreshData(recordJson1, currentLatStr, currentLongStr, shop1.id);
        NewSampleInspectorController.createRecord(testDIRJson, currentLatStr, currentLongStr);
        NewSampleInspectorController.samplingInspectionAdd(recordJson1,productTest.Id);

        NewSampleInspectorController.refreshPositioning(currentLatStr, currentLongStr, String.valueOf(System.today()), shop2.Id);
        Test.stopTest();
    }
}