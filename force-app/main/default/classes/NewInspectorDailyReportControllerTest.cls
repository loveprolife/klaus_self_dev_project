/**
 * @description       :
 * @author            : fausfeng@deloitte.com.cn
 * @group             :
 * @last modified on  : 19-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
 **/
@isTest
public class NewInspectorDailyReportControllerTest{
    @isTest
    static void testMethod1(){
        NewInspectorDailyReportController.gabige();
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
            Sales_Region__c = 'Hisense Australia', 
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
        shop1.Sales_Region__c = 'Hisense Australia';	
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90986';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        System.debug('ShopName======' + shop1.Name);
        System.debug('ShopLocation=======' + Shop1.Shop_Center_Location__c);

        //Shop__c shop1 = new Shop__c();
        //shop1.Account__c = acc.Id;
        //shop1.Shop_Level__c = 'A';
        //shop1.Name = 'CX签到测试店';
        //shop1.Shop_Center_Location__c = Location.newInstance(106.587556, 29.567932);
        //INSERT shop1;

        //Shop__c shop3 = [Select id,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s,Account__c,Name,Shop_Level__c from Shop__c where Shop_Center_Location__c != null Limit 1];
        //System.debug('+++++++------'+shop3.Shop_Center_Location__c);

        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Sales_Region__c = 'Hisense Australia';
        shop2.Shop_Level__c = 'A';
        shop2.Name = 'CX签出测试店';
        shop2.Shop_Code_Text__c = '90988';
        shop2.Grid__c = grid.id;
        shop2.Shop_Center_Location__Latitude__s = 59.4545;
        shop2.Shop_Center_Location__Longitude__s = 86.509;
        INSERT shop2;

        Shop__c shop3 = new Shop__c();
        shop3.Sales_Region__c = 'Hisense Australia';
        shop3.Account__c = acc.Id;
        shop3.Shop_Level__c = 'B';
        shop3.Name = '测试店333';
        shop3.Shop_Code_Text__c = '90998';
        shop3.Grid__c = grid.id;
        INSERT shop3;

        Shop__c shop4 = new Shop__c();
        shop4.Sales_Region__c = 'Hisense Australia';
        shop4.Account__c = acc.Id;
        shop4.Shop_Level__c = 'A';
        shop4.Name = '测试店444';
        shop4.Shop_Code_Text__c = '90997';
        shop4.Grid__c = grid.id;
        INSERT shop4;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = TIme.newInstance(18, 0, 0, 0);
        testPAR.Name = 'testPAR';
        insert testPAR;

        // Responsible_Person__c rp = new Responsible_Person__c();
        // rp.Principal__c = UserInfo.getUserId();
        // rp.RecordType__c = '巡店员';
        // rp.Shop_Name__c = shop1.Id;
        // rp.Promoter_Attendance_Rule__c = testPAR.id;
        // INSERT rp;

        //Responsible_Person__c rp2 = new Responsible_Person__c();
        //rp2.Principal__c = UserInfo.getUserId();
        //rp2.RecordType__c = '巡店员';
        //rp2.Shop_Name__c = shop2.Id;
        //INSERT rp2;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest.Name = 'NTC-22E-TV';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        //productTest.Product_Line__c = 'TV';
        //update productTest;

        Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest2.Name = 'NTC-24E-TV';
        productTest2.CurrencyIsoCode = 'USD';
        productTest2.Product_External_Id__c = 'NTC-24E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'Category';
        Insert productTest2;

        Product__c productTest3 = new Product__c();
        productTest3.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest3.Name = 'NTC-333E-TV';
        productTest3.CurrencyIsoCode = 'USD';
        productTest3.Product_External_Id__c = 'NTC-333E-TV';
        productTest3.Series__c = 'hisense tv';
        productTest3.Category__c = 'Category';
        Insert productTest3;

        Product__c productTest4 = new Product__c();
        productTest4.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest4.Name = 'NTC-444E-TV';
        productTest4.CurrencyIsoCode = 'USD';
        productTest4.Product_External_Id__c = 'NTC-444E-TV';
        productTest4.Series__c = 'hisense tv';
        productTest4.Category__c = 'Category';
        Insert productTest4;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Date.today().year() + '';
        ispTest.Inspection_Month__c = Date.today().month() + '';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Daily_Inspection_Report__c testDIR2 = new Daily_Inspection_Report__c();
        testDIR2.Report_Date__c = System.today();
        testDIR2.Inspection_Shop_Plan__c = ispTest.id;
        testDIR2.Store__c = shop2.id;
        testDIR2.OwnerId = user1.id;
        testDIR2.Status__c = 'New';
        testDIR2.NeedCheckIn__c = true;
        Insert testDIR2;

        Daily_Inspection_Report__c testDIR3 = new Daily_Inspection_Report__c();
        testDIR3.Report_Date__c = System.today();
        testDIR3.Inspection_Shop_Plan__c = ispTest.id;
        testDIR3.Store__c = shop3.id;
        testDIR3.OwnerId = user1.id;
        testDIR3.Status__c = 'New';
        testDIR3.NeedCheckIn__c = true;
        Insert testDIR3;

        Daily_Inspection_Report__c testDIR4 = new Daily_Inspection_Report__c();
        testDIR4.Report_Date__c = System.today();
        testDIR4.Inspection_Shop_Plan__c = ispTest.id;
        testDIR4.Store__c = shop4.id;
        testDIR4.OwnerId = user1.id;
        testDIR4.Status__c = 'New';
        testDIR4.NeedCheckIn__c = true;
        Insert testDIR4;

        Daily_Inspection_Report__c testDIR5 = new Daily_Inspection_Report__c();
        testDIR5.Report_Date__c = System.today();
        testDIR5.Inspection_Shop_Plan__c = ispTest.id;
        testDIR5.Store__c = shop1.id;
        testDIR5.OwnerId = user1.id;
        testDIR5.Status__c = 'New';
        testDIR5.NeedCheckIn__c = true;
        Insert testDIR5;

        Promoter_Attendance__c testPA = new Promoter_Attendance__c();
        testPA.CheckInStatus__c = '未签到';
        testPA.OwnerId = UserInfo.getUserId();
        testPA.CheckIn_Date__c = System.today();
        testPA.Shop__c = shop1.id;
        //testPA.SignInTime__c = Time.newInstance(09,17,30,0);
        //testPA.SignOutTime__c = Time.newInstance(20,18,0,0);
        //testPA.Shop__c = shop1.id;
        //testPA.ExternalId__c = user1.id + '_' + String.valueOf(System.today());
        testPA.CheckOutShop__c = shop2.id;
        testPA.ApprovalStatus__c = '补签申请审批通过';
        Insert testPA;

        Promoter_Attendance_Information__c testPAI = new Promoter_Attendance_Information__c();
        testPAI.CheckIn_Date__c = System.today();
        testPAI.CheckIn_Time__c = Time.newInstance(20, 18, 0, 0);
        testPAI.Shop__c = shop1.id;
        testPAI.Remark__c = '测试PAI';
        testPAI.Type__c = 'Check in';
        testPAI.Promoter_Attendance__c = testPA.id;
        Insert testPAI;

        Date date1 = Date.today();
        Inspection_Shop_Task__c testIST = new Inspection_Shop_Task__c();
        testIST.Shop__c = shop1.Id;
        testIST.ExternalId__c = acc.Id;
        testIST.OwnerId = user1.Id;
        testIST.Status__c = '已到访';
        testIST.Inspection_Plan__c = ispTest.id;
        testIST.Inspection_Date__c = date1;
        INSERT testIST;

        CheckItem__c testCI = new CheckItem__c();
        testCI.Description__c = 'old';
        testCI.Active__c = true;
        testCI.BussinessArea__c = 'Chile';
        testCI.MaximumScore__c = '5';
        //testCI.Product_Line__c = 'TV';
        testCI.Project__c = 'Booth and image';
        testCI.HasFile__c = false;
        testCI.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        testCI.OrderNumber__c = 10;
        Insert testCI;

        CheckItem__c testCI2 = new CheckItem__c();
        testCI2.Description__c = 'new';
        testCI2.Active__c = true;
        testCI2.BussinessArea__c = 'South Africa';
        testCI2.MaximumScore__c = '5';
        //testCI.Product_Line__c = 'TV';
        testCI2.Project__c = 'Booth and image';
        testCI2.HasFile__c = true;
        testCI2.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('South Africa').getRecordTypeId();
        testCI2.OrderNumber__c = 10;
        Insert testCI2;

        CheckResult__c testCR = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR.CheckItem__c = testCI.Id;
        testCR.Scores__c = 2;
        testCR.Comments__c = '测试CR用';
        testCR.Status__c = 'Submitted';
        testCR.InspectorDailyReport__c = testDIR.id;
        Insert testCR;

        CheckResult__c testCR2 = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR2.CheckItem__c = testCI2.Id;
        testCR2.Scores__c = 2;
        testCR2.Comments__c = '测试CR用';
        testCR2.Status__c = 'Submitted';
        testCR2.InspectorDailyReport__c = testDIR5.id;
        Insert testCR2;

        // ContentDocumentLink testContent = new ContentDocumentLink();
        // testContent.LinkedEntityId = testCR.id;
        // testContent.ContentDocumentId = '0690o000007BKH5AAO';
        // insert testContent;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink testContent = New ContentDocumentLink();
        testContent.LinkedEntityId = testCR2.id;
        testContent.ContentDocumentId = documents[0].Id;
        // testContent.shareType = 'V';
        insert testContent;  


        Task testTask1 = new Task();
        testTask1.Status = 'Open';
        testTask1.OwnerId = user1.id;
        testTask1.WhatId = testDIR.id;
        testTask1.Description = '测试CR的task';
        //testTask1.CreatedDate = System.today();
        testTask1.Subject = 'Send Letter';
        testTask1.Priority = 'Low';
        //testTask1.CreatedById = user1.id;
        //Insert testTask1;

        Task testTask2 = new Task();
        testTask2.Status = 'Closed';
        testTask2.OwnerId = user1.id;
        testTask2.WhatId = testDIR.id;
        testTask2.Description = '测试CR的task';
        testTask2.Subject = 'Send Letter';
        testTask2.Priority = 'Low';
        //Insert testTask2;

        Mileage__c testMileage = new Mileage__c();
        testMileage.Report__c = testDIR.id;
        testMileage.Start__c = 10;
        testMileage.End__c = 20;
        Insert testMileage;

        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        testSM.Shop_Level__c = 'A';
        testSM.Level__c = 'A';
        testSM.OwnerId = user1.id;
        testSM.RecordTypeId = Schema.SObjectType.Sampling_Mapping__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        Insert testSM;

        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest2.id;
        testSS.OwnerId = user1.id;
        testSS.Is_Add_ByReport__c = true;
        //testSS.Sampling_Mapping__c = testSM.id;
        Insert testSS;

        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop1.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest2.id;
        testSD.Sampling_Standard__c = testSS.id;
        //Insert testSD;

        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest2.id;
        testSI1.Shop__c = shop2.id;
        testSI1.Sample_Item__c = testSD.id;
        testSI1.ReRe__c = '测试rere1';
        testSI1.ExternalID__c = String.valueOf(testDIR2.Report_Date__c) + '_' + testDIR2.Store__c + '_' + productTest2.Id;
        //Insert testSI1;

        Sampling_Inspection__c testSI2 = new Sampling_Inspection__c();
        testSI2.Inspection_Date__c = System.today();
        testSI2.Placement_Status__c = '展出';
        testSI2.Unplanned_Sample__c = 'Yes';
        testSI2.Product__c = productTest2.id;
        testSI2.Shop__c = shop1.id;
        testSI2.Sample_Item__c = testSD.id;
        testSI2.ReRe__c = '测试rere2';
        testSI2.ExternalID__c = String.valueOf(testDIR.Report_Date__c) + '_' + testDIR.Store__c + '_' + productTest2.Id;
        //Insert testSI2;

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

        String mileageRecordJson = JSON.serialize(testMileage);

        boolean isSubmit = true;

        List<CheckResult__c> checkList = new List<CheckResult__c>();
        checkList.add(testCR);
        String checkListJson = JSON.serialize(checkList);

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
        NewInspectorDailyReportController.getInitData(testDIR.id, currentLatStr, currentLongStr, '');
        NewInspectorDailyReportController.getInitData(null, currentLatStr, null, '');
        NewInspectorDailyReportController.refreshData(recordJson1, currentLatStr, currentLongStr, testCV.id, '');
        NewInspectorDailyReportController.createRecord(testDIRJson, 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
        NewInspectorDailyReportController.samplingInspectionAdd(recordJson1,productTest.Id);

        //NewInspectorDailyReportController.upsertRecord(testDIRJson, '{}', '{}', '{}', '{}', '{}', '{}', false, attendancePhotoStreamJson,  'attendanceRemark');
        NewInspectorDailyReportController.refreshPositioning(currentLatStr, currentLongStr, String.valueOf(System.today()), '');
        // NewInspectorDailyReportController.addPlanOutProduct(recordJson1,productTest3.id);
        // NewInspectorDailyReportController.delProductLine(recordJson1,'TV');
        // NewInspectorDailyReportController.getPickList('Task','Status');
        // NewInspectorDailyReportController.SubmitReport(testDIR,checkList);
        NewInspectorDailyReportController.getRewriteCheckResult(testDIR5.Id);
        NewInspectorDailyReportController.getProductSeriesOption('TV');
        NewInspectorDailyReportController.updateSamplingDetail(inList);
        Test.stopTest();
    }

    @isTest
    static void testMethod1_2(){
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
            Sales_Region__c = 'Hisense Australia', 
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
        shop1.Sales_Region__c = 'Hisense Australia';
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90996';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        System.debug('ShopName======' + shop1.Name);
        System.debug('ShopLocation=======' + Shop1.Shop_Center_Location__c);

        //Shop__c shop1 = new Shop__c();
        //shop1.Account__c = acc.Id;
        //shop1.Shop_Level__c = 'A';
        //shop1.Name = 'CX签到测试店';
        //shop1.Shop_Center_Location__c = Location.newInstance(106.587556, 29.567932);
        //INSERT shop1;

        //Shop__c shop3 = [Select id,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s,Account__c,Name,Shop_Level__c from Shop__c where Shop_Center_Location__c != null Limit 1];
        //System.debug('+++++++------'+shop3.Shop_Center_Location__c);

        Shop__c shop2 = new Shop__c();
        shop2.Sales_Region__c = 'Hisense Australia';
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Name = 'CX签出测试店';
        shop2.Shop_Code_Text__c = '90995';
        shop2.Grid__c = grid.id;
        //shop2.Shop_Center_Location__Latitude__s = 59.4545;
        //shop2.Shop_Center_Location__Longitude__s = 86.509;
        INSERT shop2;

        Shop__c shop3 = new Shop__c();
        shop3.Sales_Region__c = 'Hisense Australia';
        shop3.Account__c = acc.Id;
        shop3.Shop_Code_Text__c = '90994';
        shop3.Grid__c = grid.id;
        shop3.Shop_Level__c = 'B';
        shop3.Name = '测试店333';
        INSERT shop3;

        Shop__c shop4 = new Shop__c();
        shop4.Sales_Region__c = 'Hisense Australia';
        shop4.Account__c = acc.Id;
        shop4.Shop_Code_Text__c = '90993';
        shop4.Grid__c = grid.id;
        shop4.Shop_Level__c = 'A';
        shop4.Name = '测试店444';
        INSERT shop4;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = TIme.newInstance(18, 0, 0, 0);
        testPAR.Name = 'testPAR';
        insert testPAR;

        // Responsible_Person__c rp = new Responsible_Person__c();
        // rp.Principal__c = UserInfo.getUserId();
        // rp.RecordType__c = '巡店员';
        // rp.Shop_Name__c = shop1.Id;
        // rp.Promoter_Attendance_Rule__c = testPAR.id;
        // INSERT rp;

        //Responsible_Person__c rp2 = new Responsible_Person__c();
        //rp2.Principal__c = UserInfo.getUserId();
        //rp2.RecordType__c = '巡店员';
        //rp2.Shop_Name__c = shop2.Id;
        //INSERT rp2;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest.Name = 'NTC-22E-TV';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        //productTest.Product_Line__c = 'TV';
        //update productTest;

        Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest2.Name = 'NTC-24E-TV';
        productTest2.CurrencyIsoCode = 'USD';
        productTest2.Product_External_Id__c = 'NTC-24E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'Category';
        Insert productTest2;

        Product__c productTest3 = new Product__c();
        productTest3.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest3.Name = 'NTC-333E-TV';
        productTest3.CurrencyIsoCode = 'USD';
        productTest3.Product_External_Id__c = 'NTC-333E-TV';
        productTest3.Series__c = 'hisense tv';
        productTest3.Category__c = 'Category';
        Insert productTest3;

        Product__c productTest4 = new Product__c();
        productTest4.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest4.Name = 'NTC-444E-TV';
        productTest4.CurrencyIsoCode = 'USD';
        productTest4.Product_External_Id__c = 'NTC-444E-TV';
        productTest4.Series__c = 'hisense tv';
        productTest4.Category__c = 'Category';
        Insert productTest4;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Date.today().year() + '';
        ispTest.Inspection_Month__c = Date.today().month() + '';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Daily_Inspection_Report__c testDIR2 = new Daily_Inspection_Report__c();
        testDIR2.Report_Date__c = System.today();
        testDIR2.Inspection_Shop_Plan__c = ispTest.id;
        testDIR2.Store__c = shop2.id;
        testDIR2.OwnerId = user1.id;
        testDIR2.Status__c = 'New';
        testDIR2.NeedCheckIn__c = true;
        Insert testDIR2;

        Daily_Inspection_Report__c testDIR3 = new Daily_Inspection_Report__c();
        testDIR3.Report_Date__c = System.today();
        testDIR3.Inspection_Shop_Plan__c = ispTest.id;
        testDIR3.Store__c = shop3.id;
        testDIR3.OwnerId = user1.id;
        testDIR3.Status__c = 'New';
        testDIR3.NeedCheckIn__c = true;
        Insert testDIR3;

        Daily_Inspection_Report__c testDIR4 = new Daily_Inspection_Report__c();
        testDIR4.Report_Date__c = System.today();
        testDIR4.Inspection_Shop_Plan__c = ispTest.id;
        testDIR4.Store__c = shop4.id;
        testDIR4.OwnerId = user1.id;
        testDIR4.Status__c = 'New';
        testDIR4.NeedCheckIn__c = true;
        Insert testDIR4;

        Daily_Inspection_Report__c testDIR5 = new Daily_Inspection_Report__c();
        testDIR5.Report_Date__c = System.today();
        testDIR5.Inspection_Shop_Plan__c = ispTest.id;
        testDIR5.Store__c = shop1.id;
        testDIR5.OwnerId = user1.id;
        testDIR5.Status__c = 'New';
        testDIR5.NeedCheckIn__c = true;
        Insert testDIR5;

        Promoter_Attendance__c testPA = new Promoter_Attendance__c();
        testPA.CheckInStatus__c = '未签到';
        testPA.OwnerId = UserInfo.getUserId();
        testPA.CheckIn_Date__c = System.today();
        testPA.Shop__c = shop1.id;
        //testPA.SignInTime__c = Time.newInstance(09,17,30,0);
        //testPA.SignOutTime__c = Time.newInstance(20,18,0,0);
        //testPA.Shop__c = shop1.id;
        //testPA.ExternalId__c = user1.id + '_' + String.valueOf(System.today());
        testPA.CheckOutShop__c = shop2.id;
        testPA.ApprovalStatus__c = '补签申请审批通过';
        Insert testPA;

        Promoter_Attendance_Information__c testPAI = new Promoter_Attendance_Information__c();
        testPAI.CheckIn_Date__c = System.today();
        testPAI.CheckIn_Time__c = Time.newInstance(20, 18, 0, 0);
        testPAI.Shop__c = shop1.id;
        testPAI.Remark__c = '测试PAI';
        testPAI.Type__c = 'Check in';
        testPAI.Promoter_Attendance__c = testPA.id;
        Insert testPAI;

        Date date1 = Date.today();
        Inspection_Shop_Task__c testIST = new Inspection_Shop_Task__c();
        testIST.Shop__c = shop1.Id;
        testIST.ExternalId__c = acc.Id;
        testIST.OwnerId = user1.Id;
        testIST.Status__c = '已到访';
        testIST.Inspection_Plan__c = ispTest.id;
        testIST.Inspection_Date__c = date1;
        INSERT testIST;

        CheckItem__c testCI = new CheckItem__c();
        testCI.Description__c = 'old';
        testCI.Active__c = true;
        testCI.BussinessArea__c = 'Chile';
        testCI.MaximumScore__c = '5';
        //testCI.Product_Line__c = 'TV';
        testCI.Project__c = 'Booth and image';
        testCI.HasFile__c = false;
        testCI.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        testCI.OrderNumber__c = 10;
        Insert testCI;

        CheckItem__c testCI2 = new CheckItem__c();
        testCI2.Description__c = 'new';
        testCI2.Active__c = true;
        testCI2.BussinessArea__c = 'South Africa';
        testCI2.MaximumScore__c = '5';
        //testCI.Product_Line__c = 'TV';
        testCI2.Project__c = 'Booth and image';
        testCI2.HasFile__c = true;
        testCI2.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('South Africa').getRecordTypeId();
        testCI2.OrderNumber__c = 10;
        Insert testCI2;

        CheckResult__c testCR = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR.CheckItem__c = testCI.Id;
        testCR.Scores__c = 2;
        testCR.Comments__c = '测试CR用';
        testCR.Status__c = 'Submitted';
        testCR.InspectorDailyReport__c = testDIR.id;
        Insert testCR;

        CheckResult__c testCR2 = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR2.CheckItem__c = testCI2.Id;
        testCR2.Scores__c = 2;
        testCR2.Comments__c = '测试CR用';
        testCR2.Status__c = 'Submitted';
        testCR2.InspectorDailyReport__c = testDIR5.id;
        Insert testCR2;

        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        // ContentDocumentLink testContent = new ContentDocumentLink();
        // testContent.LinkedEntityId = testCR2.id;
        // testContent.ContentDocumentId = '0690o000007BKH5AAO';
        // insert testContent;

        Task testTask1 = new Task();
        testTask1.Status = 'Open';
        testTask1.OwnerId = user1.id;
        testTask1.WhatId = testDIR.id;
        testTask1.Description = '测试CR的task';
        //testTask1.CreatedDate = System.today();
        testTask1.Subject = 'Send Letter';
        testTask1.Priority = 'Low';
        //testTask1.CreatedById = user1.id;
        //Insert testTask1;

        Task testTask2 = new Task();
        testTask2.Status = 'Closed';
        testTask2.OwnerId = user1.id;
        testTask2.WhatId = testDIR.id;
        testTask2.Description = '测试CR的task';
        testTask2.Subject = 'Send Letter';
        testTask2.Priority = 'Low';
        //Insert testTask2;

        Mileage__c testMileage = new Mileage__c();
        testMileage.Report__c = testDIR.id;
        testMileage.Start__c = 10;
        testMileage.End__c = 20;
        Insert testMileage;

        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        testSM.Shop_Level__c = 'A';
        testSM.Level__c = 'A';
        testSM.OwnerId = user1.id;
        testSM.RecordTypeId = Schema.SObjectType.Sampling_Mapping__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        Insert testSM;

        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest2.id;
        testSS.OwnerId = user1.id;
        testSS.Is_Add_ByReport__c = true;
        //testSS.Sampling_Mapping__c = testSM.id;
        Insert testSS;

        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop1.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest2.id;
        testSD.Sampling_Standard__c = testSS.id;
        //Insert testSD;

        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest2.id;
        testSI1.Shop__c = shop2.id;
        testSI1.Sample_Item__c = testSD.id;
        testSI1.ReRe__c = '测试rere1';
        testSI1.ExternalID__c = String.valueOf(testDIR2.Report_Date__c) + '_' + testDIR2.Store__c + '_' + productTest2.Id;
        //Insert testSI1;

        Sampling_Inspection__c testSI2 = new Sampling_Inspection__c();
        testSI2.Inspection_Date__c = System.today();
        testSI2.Placement_Status__c = '展出';
        testSI2.Unplanned_Sample__c = 'Yes';
        testSI2.Product__c = productTest2.id;
        testSI2.Shop__c = shop1.id;
        testSI2.Sample_Item__c = testSD.id;
        testSI2.ReRe__c = '测试rere2';
        testSI2.ExternalID__c = String.valueOf(testDIR.Report_Date__c) + '_' + testDIR.Store__c + '_' + productTest2.Id;
        //Insert testSI2;

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

        String mileageRecordJson = JSON.serialize(testMileage);

        boolean isSubmit = true;

        List<CheckResult__c> checkList = new List<CheckResult__c>();
        checkList.add(testCR);
        String checkListJson = JSON.serialize(checkList);

        String recordDateStr = String.valueOf(testSI1.Inspection_Date__c);

        List<Sampling_Inspection__c> inList = new List<Sampling_Inspection__c>();
        inList.add(testSI3);
        String inListJson = JSON.serialize(inList);

        List<Sampling_Inspection__c> outList = new List<Sampling_Inspection__c>();
        outList.add(testSI4);
        String outListJson = JSON.serialize(outList);

        String testDIRJson = JSON.serialize(testDIR);
        String testDIRJson2 = JSON.serialize(testDIR3);

        Competitors_Information__c ci = new Competitors_Information__c();
        ci.Daily_Inspection_Report__c = testDIR4.id;
        insert ci;

        Competitors_Information__c ci1 = new Competitors_Information__c();
        ci1.Daily_Inspection_Report__c = testDIR4.id;
        insert ci1;

        List<Competitors_Information__c> l = new List<Competitors_Information__c>();
        l.add(ci);
        l.add(ci1);
        String samplingInspectionsArgentinaJson = JSON.serialize(l);

        Test.startTest();

        NewInspectorDailyReportController.getInitData(testDIR.id, currentLatStr, currentLongStr, '');
        NewInspectorDailyReportController.getInitData(null, currentLatStr, null, '');
        NewInspectorDailyReportController.refreshData(recordJson1, currentLatStr, currentLongStr, testCV.id, '');
        NewInspectorDailyReportController.createRecord(testDIRJson, 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
        NewInspectorDailyReportController.getExistInspectionShopPlanBaseReportInfo(System.today(), UserInfo.getUserId());
        NewInspectorDailyReportController.getExistInspectionShopTaskBaseCheck(Shop1.Id, System.today(), UserInfo.getUserId());
        // NewInspectorDailyReportController.getExistSamplingDetailBaseId(new Set<String>());
        NewInspectorDailyReportController.getExistPlanOutSamplingInspectionBaseStoreId(Shop1.Id, UserInfo.getUserId(), System.today());
        NewInspectorDailyReportController.checkListSave(testDIR.id, checkListJson);
        NewInspectorDailyReportController.upsertRecord(recordJsonUpdate, samplingInspectionJson, samplingInspectionsArgentinaJson, ticketOpenJson, taskListCloseJson, ticketOpenFilesMapJson, mileageRecordJson, '[]', true, attendancePhotoStreamJson, 'attendanceRemark');
        // NewInspectorDailyReportController.refreshPositioning(currentLatStr, currentLongStr, String.valueOf(System.today()), '');
        // NewInspectorDailyReportController.addPlanOutProduct(recordJson1, productTest3.id);
        // NewInspectorDailyReportController.delProductLine(recordJson1,'TV');
        NewInspectorDailyReportController.getPickList('Task', 'Status');
        Test.stopTest();
    }

    @isTest
    static void testMethod2(){

        ConResponse makeDataResp = makeData();
        Map<String, Object> data = (Map<String, Object>)makeDataResp.data;

        String testDIRId = String.valueOf(data.get('testDIRId'));
        String currentLatStr = String.valueOf(data.get('currentLatStr'));
        String currentLongStr = String.valueOf(data.get('currentLongStr'));
        String testDIRJson2 = String.valueOf(data.get('testDIRJson2'));
        String testCVId = String.valueOf(data.get('testCVId'));
        String productTest2Id = String.valueOf(data.get('productTest2Id'));
        String testCIProductLine = String.valueOf(data.get('testCIProductLine'));
        String testCIProject = String.valueOf(data.get('testCIProject'));

        Test.startTest();
        // NewInspectorDailyReportController.getInitData(testDIRId, currentLatStr, currentLongStr);
        // NewInspectorDailyReportController.refreshData(testDIRJson2, currentLatStr, currentLongStr, testCVId);
        // NewInspectorDailyReportController.SubmitReport(testDIR3,checkResultList);
        NewInspectorDailyReportController.queryProduct(productTest2Id);
        NewInspectorDailyReportController.checkListGetInitData(testDIRId, testCIProductLine, testCIProject);
        Test.stopTest();
    }

    // @isTest
    // static void testMethod2_1(){
    //     Test.startTest();
    //     NewInspectorDailyReportController.checkListSave(data.testDIRId, checkListJson);
    //     //NewInspectorDailyReportController.getCheckResult(testDIR5.Id);
    //     NewInspectorDailyReportController.samplingInspectionGetInitData(shop1.id,recordDateStr,'TV');
    //     NewInspectorDailyReportController.samplingInspectionSave(inListJson,outListJson);
    //     NewInspectorDailyReportController.samplingInspectionAdd(data.testDIRJson2,productTest4.id);
    //     NewInspectorDailyReportController.updateSamplingDetail(outList);
    //     NewInspectorDailyReportController.createSamplingInspection(testStoreId,testReportDate);
    //     Sampling_Inspection__c deleSI = [select id,ReRe__c from Sampling_Inspection__c where Product__c = :productTest3.id AND Shop__c = :shop3.id AND Sample_Item__c = :testSD.id Limit 1];
    //   System.debug('SISISSISISIIISISI======>'+deleSI);
    //     NewInspectorDailyReportController.samplingInspectionDelete(data.testDIRJson2,deleSI.id);
    //     Test.stopTest();
    // }
    // @isTest
    static void testMethod3(){


        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :'System Administrator'].get(0).Id;
        User user1 = new User(
            alias = '促销员', 
            email = 'TestCX@noemail.com', 

            emailencodingkey = 'UTF-8', 
            lastname = 'TestCX', 
            languagelocalekey = 'en_US', 
            Sales_Region__c = 'Hisense Australiaa', 
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
        acc.Name = 'KS';
        INSERT acc;

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        INSERT sm;

        Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        INSERT ss;

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        INSERT sd;

        List<Sampling_Inspection__c> newSiList = new List<Sampling_Inspection__c>();
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.ExternalID__c = 'new';
        newSi.Sample_Item__c = sd.Id;
        insert newSi;
        newSiList.add(newSi);

        List<Sampling_Inspection__c> oldSiList = new List<Sampling_Inspection__c>();
        Sampling_Inspection__c oldSi = new Sampling_Inspection__c();
        oldSi.ExternalID__c = 'old';
        oldSi.Sample_Item__c = sd.Id;
        insert oldSi;
        oldSiList.add(oldSi);

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.Description__c = 'old';
        checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense Australiaa';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Booth and image';
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('South Africa').getRecordTypeId();
        Insert checkItem;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Sales_Region__c = 'Hisense Australia';
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90992';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        Daily_Inspection_Report__c inspection = new Daily_Inspection_Report__c();
        inspection.Report_Date__c = System.today().addDays(-1);
        inspection.Store__c = shop1.Id;
        inspection.Status__c = 'Submitted';
        inspection.OwnerId = user1.Id;
        insert inspection;

        CheckResult__c cr = new CheckResult__c();
        cr.CheckItem__c = checkItem.Id;
        cr.InspectorDailyReport__c = inspection.Id;
        insert cr;

        Daily_Inspection_Report__c newInspection = new Daily_Inspection_Report__c();
        newInspection.Report_Date__c = System.today();
        newInspection.Store__c = shop1.Id;
        newInspection.Status__c = 'Submitted';
        newInspection.OwnerId = user1.Id;
        insert newInspection;

        List<CheckResult__c> newCrList = new List<CheckResult__c>();
        CheckResult__c newCr = new CheckResult__c();
        newCr.CheckItem__c = checkItem.Id;
        newCr.InspectorDailyReport__c = newInspection.Id;
        insert newCr;
        newCrList.add(newCr);

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('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');
        cv.Title = '新建文本文档.txt';
        cv.PathOnClient = '新建文本文档.txt';
        insert cv;

        ContentVersion qrcv = [SELECT Id, ContentDocumentId
                               FROM ContentVersion
                               WHERE Id = :cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = oldSi.Id;
        cdl.ShareType = 'V';

        insert cdl;

        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = qrcv.ContentDocumentId;
        cdl2.LinkedEntityId = cr.Id;
        cdl2.ShareType = 'V';

        insert cdl2;

        System.runAs(user1){
            NewInspectorDailyReportController.samplingInspectionBindAttachments(newSiList, oldSiList);
            NewInspectorDailyReportController.checkItemBindAttachments(newCrList, shop1.Id, user1.Id);
        }
    }

    public static ConResponse makeData(){

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        resp.data = mso;

        String profileName = '促销员';
        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :profileName][0].Id;
        User user1 = new User(
            alias = '促销员', 
            email = 'TestCX@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'TestCX', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testCX@noemail.com'
        );
        INSERT user1;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        List<Shop__c> storeList = new List<Shop__c>();
        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID2';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Sales_Region__c = 'Hisense Australia';
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90991';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;
        // Insert shop1;
        storeList.add(shop1);

        System.debug('ShopName======' + shop1.Name);
        System.debug('ShopLocation=======' + Shop1.Shop_Center_Location__c);

        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Sales_Region__c = 'Hisense Australia';
        shop2.Shop_Level__c = 'A';
        shop2.Name = 'CX签出测试店';
        shop2.Shop_Code_Text__c = '90822';
        shop2.Grid__c = grid.id;
        shop2.Shop_Center_Location__Latitude__s = 29.4545;
        shop2.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop2;
        // storeList.add(shop2);

        Shop__c shop3 = new Shop__c();
        shop3.Account__c = acc.Id;
        shop3.Shop_Level__c = 'B';
        shop3.Sales_Region__c = 'Hisense Australia';
        shop3.Name = '测试店333';
        shop3.Shop_Code_Text__c = '90558';
        shop3.Shop_Center_Location__Latitude__s = 29.4545;
        shop3.Shop_Center_Location__Longitude__s = 106.509;
        shop3.Grid__c = grid.id;
        Insert shop3;
        // storeList.add(shop3);
        Shop__c shop4 = new Shop__c();
        shop4.Sales_Region__c = 'Hisense Australia';
        shop4.Account__c = acc.Id;
        shop4.Shop_Level__c = 'A';
        shop4.Shop_Code_Text__c = '90588';
        shop4.Shop_Center_Location__Latitude__s = 29.4545;
        shop4.Shop_Center_Location__Longitude__s = 106.509;
        shop4.Grid__c = grid.id;
        shop4.Name = '测试店444';
        Insert shop4;
        // storeList.add(shop4);
        // insert storeList;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = TIme.newInstance(18, 0, 0, 0);
        testPAR.Name = 'testPAR';
        insert testPAR;

        List<Responsible_Person__c> personList = new List<Responsible_Person__c>();
        // Responsible_Person__c rp = new Responsible_Person__c();
        // rp.Principal__c = UserInfo.getUserId();
        // rp.RecordType__c = '巡店员';
        // rp.Shop_Name__c = shop1.Id;
        // rp.Promoter_Attendance_Rule__c = testPAR.id;
        // // INSERT rp;
        // personList.add(rp);

        // Responsible_Person__c rp2 = new Responsible_Person__c();
        // rp2.Principal__c = UserInfo.getUserId();
        // rp2.RecordType__c = '巡店员';
        // rp2.Shop_Name__c = shop2.Id;
        // rp2.Promoter_Attendance_Rule__c = testPAR.id;
        // // INSERT rp2;
        // personList.add(rp2);
        // insert personList;

        List<Product__c> productList = new List<Product__c>();
        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest.Name = 'NTC-22E-TV';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        // Insert productTest;
        productList.add(productTest);
        //productTest.Product_Line__c = 'TV';
        //update productTest;

        Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest2.Name = 'NTC-24E-TV';
        productTest2.CurrencyIsoCode = 'USD';
        productTest2.Product_External_Id__c = 'NTC-24E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'Category';
        // Insert productTest2;
        productList.add(productTest2);

        Product__c productTest3 = new Product__c();
        productTest3.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest3.Name = 'NTC-333E-TV';
        productTest3.CurrencyIsoCode = 'USD';
        productTest3.Product_External_Id__c = 'NTC-333E-TV';
        productTest3.Series__c = 'hisense tv';
        productTest3.Category__c = 'Category';
        // Insert productTest3;
        productList.add(productTest3);

        Product__c productTest4 = new Product__c();
        productTest4.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest4.Name = 'NTC-444E-TV';
        productTest4.CurrencyIsoCode = 'USD';
        productTest4.Product_External_Id__c = 'NTC-444E-TV';
        productTest4.Series__c = 'hisense tv';
        productTest4.Category__c = 'Category';
        // Insert productTest4;
        productList.add(productTest4);
        insert productList;

        List<Inspection_Shop_Plan__c> planList = new List<Inspection_Shop_Plan__c>();
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Date.today().year() + '';
        ispTest.Inspection_Month__c = Date.today().month() + '';
        // INSERT ispTest;
        planList.add(ispTest);
        insert planList;

        List<Daily_Inspection_Report__c> reportList = new List<Daily_Inspection_Report__c>();
        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        // Insert testDIR;
        reportList.add(testDIR);

        Daily_Inspection_Report__c testDIR2 = new Daily_Inspection_Report__c();
        testDIR2.Report_Date__c = System.today();
        testDIR2.Inspection_Shop_Plan__c = ispTest.id;
        testDIR2.Store__c = shop2.id;
        testDIR2.OwnerId = user1.id;
        testDIR2.Status__c = 'New';
        testDIR2.NeedCheckIn__c = true;
        // Insert testDIR2;
        reportList.add(testDIR2);

        Daily_Inspection_Report__c testDIR3 = new Daily_Inspection_Report__c();
        testDIR3.Report_Date__c = System.today();
        testDIR3.Inspection_Shop_Plan__c = ispTest.id;
        testDIR3.Store__c = shop3.id;
        testDIR3.OwnerId = user1.id;
        testDIR3.Status__c = 'New';
        testDIR3.NeedCheckIn__c = true;
        // Insert testDIR3;
        reportList.add(testDIR3);

        Daily_Inspection_Report__c testDIR4 = new Daily_Inspection_Report__c();
        testDIR4.Report_Date__c = System.today();
        testDIR4.Inspection_Shop_Plan__c = ispTest.id;
        testDIR4.Store__c = shop4.id;
        testDIR4.OwnerId = user1.id;
        testDIR4.Status__c = 'New';
        testDIR4.NeedCheckIn__c = true;
        // Insert testDIR4;
        reportList.add(testDIR4);

        Daily_Inspection_Report__c testDIR5 = new Daily_Inspection_Report__c();
        testDIR5.Report_Date__c = System.today();
        testDIR5.Inspection_Shop_Plan__c = ispTest.id;
        testDIR5.Store__c = shop1.id;
        testDIR5.OwnerId = user1.id;
        testDIR5.Status__c = 'New';
        testDIR5.NeedCheckIn__c = true;
        // Insert testDIR5;
        reportList.add(testDIR5);

        Daily_Inspection_Report__c testDIR6 = new Daily_Inspection_Report__c();
        testDIR6.Report_Date__c = System.today();
        testDIR6.Inspection_Shop_Plan__c = ispTest.id;
        testDIR6.Store__c = shop4.id;
        testDIR6.OwnerId = UserInfo.getUserId();
        testDIR6.Status__c = 'New';
        testDIR6.NeedCheckIn__c = true;
        // Insert testDIR6;
        reportList.add(testDIR6);
        insert reportList;

        Promoter_Attendance__c testPA = new Promoter_Attendance__c();
        testPA.CheckInStatus__c = '未签到';
        testPA.OwnerId = UserInfo.getUserId();
        testPA.CheckIn_Date__c = System.today();
        testPA.Shop__c = shop1.id;
        //testPA.SignInTime__c = Time.newInstance(09,17,30,0);
        //testPA.SignOutTime__c = Time.newInstance(20,18,0,0);
        //testPA.Shop__c = shop1.id;
        //testPA.ExternalId__c = user1.id + '_' + String.valueOf(System.today());
        testPA.CheckOutShop__c = shop2.id;
        testPA.ApprovalStatus__c = '补签申请审批通过';
        Insert testPA;

        Promoter_Attendance_Information__c testPAI = new Promoter_Attendance_Information__c();
        testPAI.CheckIn_Date__c = System.today();
        testPAI.CheckIn_Time__c = Time.newInstance(20, 18, 0, 0);
        testPAI.Shop__c = shop1.id;
        testPAI.Remark__c = '测试PAI';
        testPAI.Type__c = 'Check in';
        testPAI.Promoter_Attendance__c = testPA.id;
        Insert testPAI;

        Date date1 = Date.today();
        Inspection_Shop_Task__c testIST = new Inspection_Shop_Task__c();
        testIST.Shop__c = shop1.Id;
        testIST.ExternalId__c = acc.Id;
        testIST.OwnerId = user1.Id;
        testIST.Status__c = '已到访';
        testIST.Inspection_Plan__c = ispTest.id;
        testIST.Inspection_Date__c = date1;
        INSERT testIST;

        List<CheckItem__c> checkItemList = new List<CheckItem__c>();
        CheckItem__c testCI = new CheckItem__c();
        testCI.Description__c = 'old';
        testCI.Active__c = true;
        testCI.BussinessArea__c = 'Chile';
        testCI.MaximumScore__c = '5';
        //testCI.Product_Line__c = 'TV';
        testCI.Project__c = 'Booth and image';
        testCI.HasFile__c = false;
        testCI.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        testCI.OrderNumber__c = 10;
        // Insert testCI;
        checkItemList.add(testCI);

        CheckItem__c testCI2 = new CheckItem__c();
        testCI2.Description__c = 'new';
        testCI2.Active__c = true;
        testCI2.BussinessArea__c = 'South Africa';
        testCI2.MaximumScore__c = '5';
        //testCI.Product_Line__c = 'TV';
        testCI2.Project__c = 'Booth and image';
        testCI2.HasFile__c = true;
        testCI2.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('South Africa').getRecordTypeId();
        testCI2.OrderNumber__c = 10;
        // Insert testCI2;
        checkItemList.add(testCI2);
        insert checkItemList;

        List<CheckResult__c> checkResultList = new List<CheckResult__c>();
        CheckResult__c testCR = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR.CheckItem__c = testCI.Id;
        testCR.Scores__c = 2;
        testCR.Comments__c = '测试CR用';
        testCR.Status__c = 'Submitted';
        testCR.InspectorDailyReport__c = testDIR.id;
        // Insert testCR;
        checkResultList.add(testCR);

        CheckResult__c testCR2 = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR2.CheckItem__c = testCI2.Id;
        testCR2.Scores__c = 2;
        testCR2.Comments__c = '测试CR用';
        testCR2.Status__c = 'Submitted';
        testCR2.InspectorDailyReport__c = testDIR5.id;
        // Insert testCR2;
        checkResultList.add(testCR2);

        CheckResult__c testCR3 = new CheckResult__c();
        //testCR.Name = '测试CR';
        testCR3.CheckItem__c = testCI.Id;
        testCR3.Scores__c = 3;
        testCR3.Comments__c = '测试CR用';
        testCR3.Status__c = 'Submitted';
        testCR3.InspectorDailyReport__c = testDIR6.id;
        // Insert testCR3;
        checkResultList.add(testCR3);
        insert checkResultList;

        String VersionStr = 'sdsadddddddddd';
        ContentVersion testCV = new ContentVersion();
        testCV.VersionData = Blob.valueOf(JSON.serialize(VersionStr));
        testCV.Title = 'title';
        testCV.PathOnClient = 'C:/home/user/picture/image';
        Insert testCV;

        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink testContent = New ContentDocumentLink();
        testContent.LinkedEntityId = testCR2.id;
        testContent.ContentDocumentId = documents[0].Id;
        // testContent.shareType = 'V';
        insert testContent;  

        Task testTask1 = new Task();
        testTask1.Status = 'Open';
        testTask1.OwnerId = user1.id;
        testTask1.WhatId = testDIR.id;
        testTask1.Description = '测试CR的task';
        //testTask1.CreatedDate = System.today();
        testTask1.Subject = 'Send Letter';
        testTask1.Priority = 'Low';
        //testTask1.CreatedById = user1.id;
        //Insert testTask1;

        Task testTask2 = new Task();
        testTask2.Status = 'Closed';
        testTask2.OwnerId = user1.id;
        testTask2.WhatId = testDIR.id;
        testTask2.Description = '测试CR的task';
        testTask2.Subject = 'Send Letter';
        testTask2.Priority = 'Low';
        //Insert testTask2;

        Mileage__c testMileage = new Mileage__c();
        testMileage.Report__c = testDIR.id;
        testMileage.Start__c = 10;
        testMileage.End__c = 20;
        Insert testMileage;

        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        testSM.Shop_Level__c = 'A';
        testSM.Level__c = 'A';
        testSM.OwnerId = user1.id;
        testSM.RecordTypeId = Schema.SObjectType.Sampling_Mapping__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        Insert testSM;

        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest2.id;
        testSS.OwnerId = user1.id;
        testSS.Is_Add_ByReport__c = true;
        //testSS.Sampling_Mapping__c = testSM.id;
        Insert testSS;

        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop1.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest2.id;
        testSD.Sampling_Standard__c = testSS.id;
        Insert testSD;
        //Sampling_Detail__c testSD1 = new Sampling_Detail__c();
        List<Sampling_Detail__c> sdList = [select id, Shop__c
                                           from Sampling_Detail__c];
        Sampling_Detail__c testSD1 = sdList.get(0);
        system.debug('sdList：' + sdList);
        system.debug('testSD1__id：' + testSD1.Id);
        system.debug('testSD1__shopId：' + testSD1.Shop__c);

        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest2.id;
        testSI1.Shop__c = shop2.id;
        testSI1.Sample_Item__c = testSD.id;
        testSI1.ReRe__c = '测试rere1';
        testSI1.ExternalID__c = String.valueOf(testDIR2.Report_Date__c) + '_' + testDIR2.Store__c + '_' + productTest2.Id;
        //Insert testSI1;

        Sampling_Inspection__c testSI2 = new Sampling_Inspection__c();
        testSI2.Inspection_Date__c = System.today();
        testSI2.Placement_Status__c = '展出';
        testSI2.Unplanned_Sample__c = 'Yes';
        testSI2.Product__c = productTest2.id;
        testSI2.Shop__c = shop1.id;
        testSI2.Sample_Item__c = testSD.id;
        testSI2.ReRe__c = '测试rere2';
        testSI2.ExternalID__c = String.valueOf(testDIR.Report_Date__c) + '_' + testDIR.Store__c + '_' + productTest2.Id;
        //Insert testSI2;

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
        testSI4.Unplanned_Sample__c = 'No';
        testSI4.Product__c = productTest4.id;
        testSI4.Shop__c = shop4.id;
        testSI4.Sample_Item__c = testSD1.id;
        testSI4.ReRe__c = '测试rere3';
        testSI4.ExternalID__c = String.valueOf(testDIR4.Report_Date__c) + '_' + testDIR4.Store__c + '_' + productTest4.Id;

        String currentLatStr = '86.587556';
        String currentLongStr = '29.567932';

        String recordJson1 = JSON.serialize(testDIR);
        String recordJsonUpdate = JSON.serialize(testDIR5);
        String recordJsonUpdate2 = JSON.serialize(testDIR4);
        String recordJsonUpdate3 = JSON.serialize(testDIR6);

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

        String mileageRecordJson = JSON.serialize(testMileage);

        boolean isSubmit = true;

        List<CheckResult__c> checkList = new List<CheckResult__c>();
        checkList.add(testCR);
        String checkListJson = JSON.serialize(checkList);

        String recordDateStr = String.valueOf(testSI1.Inspection_Date__c);

        List<Sampling_Inspection__c> inList = new List<Sampling_Inspection__c>();
        inList.add(testSI3);
        String inListJson = JSON.serialize(inList);

        List<Sampling_Inspection__c> outList = new List<Sampling_Inspection__c>();
        outList.add(testSI4);
        String outListJson = JSON.serialize(outList);

        String testDIRJson = JSON.serialize(testDIR);
        String testDIRJson2 = JSON.serialize(testDIR3);

        String testStoreId = testSD1.Shop__c;
        Date testReportDate = Date.newInstance(2024, 8, 8);

        // List<CheckResult__c> checkResultList = new List<CheckResult__c>();

        mso.put('testDIRId', testDIR.id);
        mso.put('currentLatStr', currentLatStr);
        mso.put('currentLongStr', currentLongStr);
        mso.put('testDIRJson2', testDIRJson2);
        mso.put('testCVId', testCV.Id);
        mso.put('productTest2Id', productTest2.id);
        mso.put('testCIProductLine', testCI.Product_Line__c);
        mso.put('testCIProject', testCI.Project__c);

        return resp;
    }

}