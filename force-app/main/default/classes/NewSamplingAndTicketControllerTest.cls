@isTest
public with sharing class NewSamplingAndTicketControllerTest{

    @isTest
    static void testMethod1(){
        NewSamplingAndTicketController.gabige();

        // Daily_Inspection_Report__c report = new Daily_Inspection_Report__c();
        // List<CheckResult__c> checkResultList = new List<CheckResult__c>();

        // NewSamplingAndTicketController.getSamplingInspectionFillInValue('');
        // NewSamplingAndTicketController.getRewriteInitData('', '', '');
        // NewSamplingAndTicketController.getPictureList('');
        // NewSamplingAndTicketController.deletePicture('');
        // NewSamplingAndTicketController.getPictureLists(ls);
        // NewSamplingAndTicketController.getShopInfo('');
        // NewSamplingAndTicketController.createSamplingInspectionRecord('', '', '', '', '', '', '');
        // NewSamplingAndTicketController.upsertRecord('', '', '', '', '', '', '', '', true, '', '');
        // NewSamplingAndTicketController.SubmitReport(report, checkResultList, '', '');
        // NewSamplingAndTicketController.();
        // NewSamplingAndTicketController.();
        // NewSamplingAndTicketController.();
        // NewSamplingAndTicketController.();
        // NewSamplingAndTicketController.();
        // NewSamplingAndTicketController.();
        // NewSamplingAndTicketController.();
    }

    @isTest
    static void testMethod8(){

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
        // shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90999';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        System.debug('ShopName======' + shop1.Name);
        System.debug('ShopLocation=======' + Shop1.Shop_Center_Location__c);

        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        // shop2.Shop_Level__c = 'A';
        shop2.Shop_Code_Text__c = '90977';
        shop2.Grid__c = grid.id;
        shop2.Name = 'CX签出测试店';
        INSERT shop2;

        Shop__c shop3 = new Shop__c();
        shop3.Account__c = acc.Id;
        shop3.Grid__c = grid.id;
        shop3.Shop_Code_Text__c = '90997';
        // shop3.Shop_Level__c = 'B';
        shop3.Name = '测试店333';
        INSERT shop3;

        Shop__c shop4 = new Shop__c();
        shop4.Grid__c = grid.id;
        shop4.Account__c = acc.Id;
        // shop4.Shop_Level__c = 'A';
        shop4.Name = '测试店444';
        shop4.Shop_Code_Text__c = '90888';
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

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2034';
        ispTest.Inspection_Month__c = '8';
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
        testCI2.Project__c = 'Booth and image';
        testCI2.HasFile__c = true;
        testCI2.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('South Africa').getRecordTypeId();
        testCI2.OrderNumber__c = 10;
        Insert testCI2;

        CheckResult__c testCR = new CheckResult__c();
        testCR.CheckItem__c = testCI.Id;
        testCR.Scores__c = 2;
        testCR.Comments__c = '测试CR用';
        testCR.Status__c = 'Submitted';
        testCR.InspectorDailyReport__c = testDIR.id;
        Insert testCR;

        CheckResult__c testCR2 = new CheckResult__c();
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
        testTask1.Subject = 'Send Letter';
        testTask1.Priority = 'Low';

        Task testTask2 = new Task();
        testTask2.Status = 'Closed';
        testTask2.OwnerId = user1.id;
        testTask2.WhatId = testDIR.id;
        testTask2.Description = '测试CR的task';
        testTask2.Subject = 'Send Letter';
        testTask2.Priority = 'Low';

        Mileage__c testMileage = new Mileage__c();
        testMileage.Report__c = testDIR.id;
        testMileage.Start__c = 10;
        testMileage.End__c = 20;
        Insert testMileage;

        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        // testSM.Shop_Level__c = 'A';
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
        NewSamplingAndTicketController.gabige();
        NewSamplingAndTicketController.refreshData(recordJson1, currentLatStr, currentLongStr, testCV.id, '');
        Test.stopTest();
    }
    @isTest
    static void testMethod9(){

        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Sales_Region__c = 'Hisense Mexico';
        // shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90999';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Inspection_Product_Item__c inspectionProductItem = new Inspection_Product_Item__c();
        inspectionProductItem.Inspection_Report__c = testDIR.Id;
        inspectionProductItem.Type__c = 'CE';
        inspectionProductItem.Product_Line__c = 'TV';
        inspectionProductItem.Status__c = 'Start';
        Insert inspectionProductItem;

        Ticket__c tik = new Ticket__c();
        tik.Status__c = 'Open';
        tik.Store__c = shop1.id;
        tik.ClosedDailyInspectionReport__c = testDIR.Id;
        insert tik;

        Ticket__c tik1 = new Ticket__c();
        tik1.Status__c = 'Open';
        tik1.Store__c = shop1.id;
        tik1.InspectionReport__c = testDIR.Id;
        insert tik1;

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('USA').getRecordTypeId();
		checkItem.Description__c = 'old';
		checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense USA';
        checkItem.Item_Type__c ='Sampling Product Check';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Booth and image';
        checkItem.Check_Item_Type__c = '巡店';
        checkItem.Question_Type__c = 'Text';
        checkItem.DescriptionT__c = 'POP';
        INSERT checkItem;

        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.OwnerId = user.Id;
        pro.RecordTypeId = recordId3;
        pro.Product_line__c = 'TV';
        INSERT pro;
        
        Product_line_Detail__c pld = new Product_line_Detail__c();
        pld.Sales_Region__c = user.Sales_Region__c;
        pld.Product_Line__c = 'TV';
        pld.Display_Type__c = 'XXX';
        INSERT pld;

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        // sm.Shop_Level__c = 'A';
        INSERT sm;
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        ss.Is_Added__c = '是';
        ss.Level__c = 'A';
        INSERT ss; 

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        sd.Shop__c = shop1.Id;
        sd.Is_Add__c = '是';
        sd.ExternalID__c = shop1.Id+'-'+pro.Id;
        
        // INSERT sd;
        

        Test.startTest();
        // NewSamplingAndTicketController.getFillInValue(inspectionProductItem.Id);
        NewSamplingAndTicketController.getRewriteInitData(inspectionProductItem.Id, 'TV', shop1.id);

        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Product_Item__c = inspectionProductItem.Id;
        si.Display_Status__c = 'yes';
        si.Shop__c = shop1.id;
        si.product__c = pro.Id;
        INSERT si;

        Ticket__c tik2 = new Ticket__c();
        tik2.Status__c = 'Open';
        tik2.Store__c = shop1.id;
        tik2.InspectionReport__c = testDIR.Id;
        String TicketJson = String.valueOf(tik2);

        NewSamplingAndTicketController.saveTicket(TicketJson);

        NewSamplingAndTicketController.samplingInspectionAdd(inspectionProductItem.Id, JSON.serialize(testDIR), 'XXX', pro.Id);

        NewSamplingAndTicketController.autoGenerateTicket(inspectionProductItem.Id, checkItem.Id, 'test');

        // NewSamplingAndTicketController.getSamplingInspectionFillInValue('','');
        // NewSamplingAndTicketController.getSamplingInspectionFillInValue(inspectionProductItem.Id,'TV');

        NewSamplingAndTicketController.getUniteFillInValue('','');
        NewSamplingAndTicketController.getUniteFillInValue(inspectionProductItem.Id,'TV');

        NewSamplingAndTicketController.getCheckListFillInValue('','');
        NewSamplingAndTicketController.getCheckListFillInValue(inspectionProductItem.Id,'TV');

        NewSamplingAndTicketController.getTicketFillInValue('');
        NewSamplingAndTicketController.getTicketFillInValue(inspectionProductItem.Id);

        // NewSamplingAndTicketController.getFillInValue('');
        NewSamplingAndTicketController.getFillInValue(inspectionProductItem.Id);

        NewSamplingAndTicketController.getRewriteInitData(inspectionProductItem.Id, 'TV', shop1.id);
        NewSamplingAndTicketController.getUniteInitData(inspectionProductItem.Id, 'TV', shop1.id);


        NewSamplingAndTicketController.getPictureList(inspectionProductItem.Id);
        NewSamplingAndTicketController.deletePicture(inspectionProductItem.Id);
        NewSamplingAndTicketController.getOfficePhoto('Hisense USA','TV');

        List<String> ids = new List<String>();
        ids.add(inspectionProductItem.Id);
        NewSamplingAndTicketController.getPictureLists(ids);
        NewSamplingAndTicketController.getShopInfo(shop1.Id);

        NewSamplingAndTicketController.samplingInspectionDelete(JSON.serialize(testDIR), si.Id);

        NewSamplingAndTicketController.getSIImageCheckResultAll(inspectionProductItem.Id);

        // NewSamplingAndTicketController.checkListSave(testDIR5.Id,checkList);
        // NewSamplingAndTicketController.checkListGetInitData();
        // getSIImageCheckResultAll
        // createTicket

        NewSamplingAndTicketController.createSamplingInspection(shop1.id,testDIR.Report_Date__c,testDIR.Id);
        NewSamplingAndTicketController.createPlanoutSamplingInspection(shop1.id,testDIR.Report_Date__c);
        NewSamplingAndTicketController.handlerRemove();


        Test.stopTest();
    }

    @isTest
    static void testMethod10(){

        

        Set<String> ids = new Set<String>();

        Test.startTest();
        NewSamplingAndTicketController.gabige();
        NewSamplingAndTicketController.getUniqueTypeValues('', System.today(), '', '', '');
        NewSamplingAndTicketController.getExistSamplingInspectionBaseId(ids);
        NewSamplingAndTicketController.getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline('', System.today(), '');
        NewSamplingAndTicketController.getExistSamplingInspectionBaseStoreIdAndDateAndProductline('', System.today(), '', '');
        Test.stopTest();
    }
}