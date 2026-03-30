@isTest
public with sharing class NewInspectorDailyReportControllerTest2 {

    public static string checkItemRecordTypeId = Schema.SobjectType.CheckItem__c.getRecordTypeInfosByDeveloperName().get('South_Africa').getRecordTypeId();
    public static string checkItemScopeRecordTypeId = Schema.SobjectType.CheckListScope__c.getRecordTypeInfosByDeveloperName().get('South_Africa').getRecordTypeId();
    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();

    public static User floorwalker = new User();
    public static Product__c product = new Product__c();
    public static Product__c product2 = new Product__c();
    public static Account customer = new Account();
    public static Shop__c store = new Shop__c();
    public static Mileage__c milleage = new Mileage__c();
    public static CheckItem__c checkItem = new CheckItem__c();
    public static CheckItem__c checkItem2 = new CheckItem__c();
    public static Sampling_Detail__c detail = new Sampling_Detail__c();

    @TestSetup
    static void makeData(){
        customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense South Africa';
        insert store;

        floorwalker = new User();
        floorwalker.Username = 'testFloorwalkerUser1213823@test004.com';
        floorwalker.lastname = 'walker';
        floorwalker.alias = 'walker';
        floorwalker.email ='Floorwalker@test.com';
        floorwalker.emailencodingkey = 'UTF-8';
        floorwalker.languagelocalekey = 'zh_CN';
        floorwalker.LocaleSidKey = 'zh_CN';
        floorwalker.IsActive = true;
        floorwalker.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%South Africa Floorwalker%'][0].Id;
        floorwalker.timezonesidkey ='Asia/Shanghai';
        floorwalker.Sales_Region__c = 'Hisense South Africa';
        insert floorwalker;

        Responsible_Person__c floorwalkerRes = new Responsible_Person__c();
        floorwalkerRes.Shop_Name__c = store.Id;
        floorwalkerRes.Principal__c = floorwalker.Id;
        floorwalkerRes.RecordType__c = '巡店员';
        insert floorwalkerRes;

        checkItem = new CheckItem__c();
        checkItem.RecordTypeId = checkItemRecordTypeId;
        checkItem.Sales_Region__c = 'Hisense South Africa';
        checkItem.Description__c = 'test321321';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Personnel';
        checkItem.Is_Related_To_Product__c = true;
        checkItem.Active__c = true;
        checkItem.Is_Remote_Inspection__c = false;

        checkItem2 = new CheckItem__c();
        checkItem2.RecordTypeId = checkItemRecordTypeId;
        checkItem2.Sales_Region__c = 'Hisense South Africa';
        checkItem2.Description__c = 'test如1让让';
        checkItem2.Project__c = 'Personnel';
        checkItem2.Active__c = true;
        checkItem2.Is_Remote_Inspection__c = false;

        CheckItem__c checkItem3 = new CheckItem__c();
        checkItem3.RecordTypeId = checkItemRecordTypeId;
        checkItem3.Sales_Region__c = 'Hisense South Africa';
        checkItem3.Description__c = 'test';
        checkItem3.Project__c = 'Personnel';
        checkItem3.Active__c = true;
        checkItem3.Is_Remote_Inspection__c = true;
        insert new List<CheckItem__c> {checkItem, checkItem2, checkItem3};

        CheckListScope__c checkScope = new CheckListScope__c();
        checkScope.CheckItem__c = checkItem.Id;
        checkScope.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope.Sales_Region__c = 'Hisense South Africa';
        checkScope.Active__c = true;

        CheckListScope__c checkScope2 = new CheckListScope__c();
        checkScope2.CheckItem__c = checkItem2.Id;
        checkScope2.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope2.Sales_Region__c = 'Hisense South Africa';
        checkScope2.Active__c = true;
        insert new List<CheckListScope__c>{checkScope, checkScope2};

        Promoter_Attendance__c attendance = new Promoter_Attendance__c();
        attendance.CheckInStatus__c = '已签到';
        attendance.Shop__c = store.Id;
        attendance.CheckOutShop__c = store.Id;
        attendance.CheckIn_Date__c = System.today();
        attendance.ExternalId__c = floorwalker.Id + '_' + String.valueOf(attendance.CheckIn_Date__c);
        insert attendance;

        Promoter_Attendance_Information__c checkInInfo = new Promoter_Attendance_Information__c();
        checkInInfo.Type__c = 'Check in';
        checkInInfo.CheckIn_Date__c = Date.today();
        checkInInfo.Shop__c = store.Id;
        checkInInfo.Promoter_Attendance__c = attendance.Id;
        checkInInfo.CheckIn_Time__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());

        Promoter_Attendance_Information__c checkOutInfo = new Promoter_Attendance_Information__c();
        checkOutInfo.Type__c = 'Check out';
        checkOutInfo.CheckIn_Date__c = Date.today();
        checkOutInfo.Shop__c = store.Id;
        checkOutInfo.Promoter_Attendance__c = attendance.Id;
        checkOutInfo.CheckIn_Time__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
        insert new List<Promoter_Attendance_Information__c>{checkInInfo, checkOutInfo};

        product = new Product__c();
        product.RecordTypeId = productRecordTypeId;
        product.Product_Line__c = 'TV';
        product.Name = 'NTC-22E-TV';
        product.Sales_Region__c = 'Hisense South Africa';

        product2 = new Product__c();
        product2.RecordTypeId = productRecordTypeId;
        product2.Product_Line__c = 'WM';
        product2.Name = 'NTC-2233E-WM';
        product2.Sales_Region__c = 'Hisense South Africa';
        insert new List<Product__c>{product, product2};

        detail = new Sampling_Detail__c();
        detail.Shop__c = store.Id;
        detail.Is_Add__c = '是';
        detail.Display_Status__c = '展出';
        detail.Product__c = product.Id;
        detail.AutomaticallyGenerateSampleStandard__c = true;
        insert detail;

        milleage = new Mileage__c();
        // milleage.Report__c = report.Id;
        milleage.Start__c = 2;
        milleage.End__c = 34;
    }

    static void getData() {
        floorwalker = [SELECT ID FROM USER WHERE Username = 'testFloorwalkerUser1213823@test004.com'];
        product =[select id, name from Product__c where Name = 'NTC-22E-TV' LIMIT 1];
        product2 =[select id, name from Product__c where Name = 'NTC-2233E-WM' LIMIT 1];
        customer = [select id, name from Account where Name = 'Wal-mart' LIMIT 1];
         store = [SELECT ID,NAME FROM Shop__c WHERE Name = 'Hi Fi Corporation NEWCASTLE' LIMIT 1];
         milleage = new Mileage__c();
        milleage.Start__c = 2;
        milleage.End__c = 34;
         checkItem = [select id, name from CheckItem__c where Is_Remote_Inspection__c = false][0];
         checkItem2 = [select id, name from CheckItem__c where Is_Remote_Inspection__c = false][1];
         detail = [select id, name from Sampling_Detail__c LIMIT 1];
    }
    
    @isTest
    static void testMethod1(){
        getData();
        Test.startTest();
        System.runAs(floorwalker) {
            String currentLatStr = '86.587556';
            String currentLongStr = '29.567932';
            ConResponse getInitDataResp = NewInspectorDailyReportController.getInitData('', currentLatStr, currentLongStr, '');
            Map<String, Object> getInitData = (Map<String, Object>) getInitDataResp.data;
            Daily_Inspection_Report__c report = (Daily_Inspection_Report__c) getInitData.get('record');
            
            String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';
            // Locale Inspection
            ConResponse createRecordResp = NewInspectorDailyReportController.createRecord(JSON.serialize(report), 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
            Map<String, Object> createRecord = (Map<String, Object>) createRecordResp.data;
            report = (Daily_Inspection_Report__c) createRecord.get('record');

            Map<String,Map<String, List<CheckResult__c>>> checkResults = (Map<String,Map<String, List<CheckResult__c>>>) createRecord.get('checkResults');
            Map<String, List<CheckResult__c>> generalMap = checkResults.get('General');
            List<CheckResult__c> crList = generalMap.get('Personnel');
            CheckResult__c checkResult = crList[0];
            checkResult.Scores__c = 3;

            List<CheckResult__c> checkResultsIsRelatedToProduct = (List<CheckResult__c>) createRecord.get('checkResultsIsRelatedToProduct');
            CheckResult__c checkResultTV = checkResultsIsRelatedToProduct[0];
            checkResultTV.Scores__c = 4;

            ConResponse checkListSaveResp = NewInspectorDailyReportController.checkListSave(report.Id, JSON.serialize(new List<CheckResult__c>{checkResult}));
            Map<String, Object> checkListSave = (Map<String, Object>) checkListSaveResp.data;
            List<Ticket__c> openTasks = (List<Ticket__c>) checkListSave.get('ticketOpenInfo');
            NewInspectorDailyReportController.checkListSave(report.Id, JSON.serialize(new List<CheckResult__c>{checkResult}));
            for(Ticket__c item : openTasks) {
                if(item.DueDate__c == null) {
                    item.DueDate__c = Date.today().addDays(7);
                    item.AssignedTo__c = floorwalker.Id;
                }
            }

            // List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>) createRecord.get('samplingInspections');
            String samplingInspectionJson = '[]';
            String ticketOpenJson = JSON.serialize(openTasks);
            String ticketClosedJson = '[]';
            String ticketOpenFilesMapJson = '{}';
            milleage.Report__c = report.Id;
            String mileageRecordJson = JSON.serialize(milleage);
            String checkResultsIsRelatedToProductJson = JSON.serialize(new List<CheckResult__c>{checkResultTV});
            Boolean isSubmit = false;
            String attendanceRemark = '';
            ConResponse upsertRecordResp = NewInspectorDailyReportController.upsertRecord(JSON.serialize(report), samplingInspectionJson, ticketOpenJson, ticketClosedJson, ticketOpenFilesMapJson, mileageRecordJson, checkResultsIsRelatedToProductJson, isSubmit, attendancePhotoStreamJson, attendanceRemark);
            Map<String, Object> upsertRecord = (Map<String, Object>) upsertRecordResp.data;
            openTasks = (List<Ticket__c>) upsertRecord.get('ticketOpenInfo');
            // for(Ticket__c item : openTasks) {
            //     if(item.DueDate__c == null) {
            //         item.DueDate__c = Date.today().addDays(7);
            //         item.AssignedTo__c = floorwalker.Id;
            //     }
            // }

            isSubmit = true;
            ticketOpenJson = JSON.serialize(openTasks);
            NewInspectorDailyReportController.upsertRecord(JSON.serialize(report), samplingInspectionJson, ticketOpenJson, ticketClosedJson, ticketOpenFilesMapJson, mileageRecordJson, checkResultsIsRelatedToProductJson, isSubmit, attendancePhotoStreamJson, attendanceRemark);

            // Remote Inspection
            // report.Inspect_Type__c = 'Remote Inspection';
        }
        Test.stopTest();
    }

    @isTest
    static void testMethod2(){
        getData();
        Shop__c store2 = new Shop__c();
        store2.Name = 'Hi Fi Corporation NEWCASTLE 33';
        store2.Account__c = customer.Id;
        store2.Sales_Region__c = 'Hisense South Africa';
        store2.Shop_Center_Location__Latitude__s = 86.587556;
        store2.Shop_Center_Location__Longitude__s = 29.567932;
        insert store2;

        
        Sampling_Detail__c detail2 = new Sampling_Detail__c();
        detail2.Shop__c = store2.Id;
        detail2.Is_Add__c = '是';
        detail2.Display_Status__c = '展出';
        detail2.Product__c = product2.Id;
        detail2.AutomaticallyGenerateSampleStandard__c = true;
        insert detail2;

        Responsible_Person__c floorwalkerRes2 = new Responsible_Person__c();
        floorwalkerRes2.Shop_Name__c = store2.Id;
        floorwalkerRes2.Principal__c = floorwalker.Id;
        floorwalkerRes2.RecordType__c = '巡店员';
        insert floorwalkerRes2;

        CheckItem__c checkItem3 = new CheckItem__c();
        checkItem3.RecordTypeId = checkItemRecordTypeId;
        checkItem3.Sales_Region__c = 'Hisense South Africa';
        checkItem3.Description__c = 'test hfaoie';
        checkItem3.Product_Line__c = 'TV';
        checkItem3.Project__c = 'Material';
        checkItem3.Active__c = true;
        checkItem3.HasComment__c = true;
        checkItem3.Require_Comment_Scores__c = '1;2;3;4;5';
        checkItem3.Is_Related_To_Product__c = true;
        checkItem3.Is_Remote_Inspection__c = false;

        CheckItem__c checkItem4 = new CheckItem__c();
        checkItem4.RecordTypeId = checkItemRecordTypeId;
        checkItem4.Sales_Region__c = 'Hisense South Africa';
        checkItem4.Description__c = 'test wuwuu';
        checkItem4.Project__c = 'Personnel';
        checkItem4.Active__c = true;
        checkItem4.Is_Remote_Inspection__c = false;
        insert new List<CheckItem__c> {checkItem3, checkItem4};

        CheckListScope__c checkScope3 = new CheckListScope__c();
        checkScope3.CheckItem__c = checkItem3.Id;
        checkScope3.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope3.Active__c = true;
        checkScope3.Sales_Region__c = 'Hisense South Africa';

        CheckListScope__c checkScope4 = new CheckListScope__c();
        checkScope4.CheckItem__c = checkItem4.Id;
        checkScope4.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope4.Sales_Region__c = 'Hisense South Africa';
        checkScope4.Active__c = true;
        insert new List<CheckListScope__c>{checkScope3, checkScope4};



        Test.startTest();
        System.runAs(floorwalker) {
            String currentLatStr = '86.587556';
            String currentLongStr = '29.567932';
            ConResponse getInitDataResp = NewInspectorDailyReportController.getInitData('', currentLatStr, currentLongStr, '');
            Map<String, Object> getInitData = (Map<String, Object>) getInitDataResp.data;
            Daily_Inspection_Report__c report = (Daily_Inspection_Report__c) getInitData.get('record');

            NewInspectorDailyReportController.refreshData(JSON.serialize(report), currentLatStr, currentLongStr, '' , '');

            String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';
            // Locale Inspection
            ConResponse createRecordResp = NewInspectorDailyReportController.createRecord(JSON.serialize(report), 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
            Map<String, Object> createRecord = (Map<String, Object>) createRecordResp.data;
            report = (Daily_Inspection_Report__c) createRecord.get('record');

            NewInspectorDailyReportController.getInitData('', currentLatStr, currentLongStr, '');
            NewInspectorDailyReportController.getInitData(report.Id, currentLatStr, currentLongStr, '');

            NewInspectorDailyReportController.refreshData(JSON.serialize(report), currentLatStr, currentLongStr, '' ,'');

            NewInspectorDailyReportController.refreshPositioning(currentLatStr, currentLongStr, String.valueOf(report.Report_Date__c),'');
            // NewInspectorDailyReportController.getStoreDistance(currentLatStr, currentLongStr, store2.Id);

            List<Sampling_Inspection__c> siList = new List<Sampling_Inspection__c>();
            String ticketOpenJson = '[]';
            String ticketClosedJson = '[]';
            String ticketOpenFilesMapJson = '{}';
            milleage.Report__c = report.Id;
            String mileageRecordJson = JSON.serialize(milleage);
            String checkResultsIsRelatedToProductJson ='[]';
            Boolean isSubmit = true;
            String attendanceRemark = '';
            NewInspectorDailyReportController.upsertRecord(JSON.serialize(report), JSON.serialize(siList), ticketOpenJson, ticketClosedJson, ticketOpenFilesMapJson, mileageRecordJson, checkResultsIsRelatedToProductJson, isSubmit, attendancePhotoStreamJson, attendanceRemark);
        }
        Test.stopTest();
    }

    @isTest
    static void testMethod3(){
        getData();
        Test.startTest();
        System.runAs(floorwalker) {
            String currentLatStr = '86.587556';
            String currentLongStr = '29.567932';

            ConResponse getInitDataResp = NewInspectorDailyReportController.getInitData('', currentLatStr, currentLongStr, '');
            Map<String, Object> getInitData = (Map<String, Object>) getInitDataResp.data;
            Daily_Inspection_Report__c report = (Daily_Inspection_Report__c) getInitData.get('record');

            String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';
            // Locale Inspection
            ConResponse createRecordResp = NewInspectorDailyReportController.createRecord(JSON.serialize(report), 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
            Map<String, Object> createRecord = (Map<String, Object>) createRecordResp.data;
            report = (Daily_Inspection_Report__c) createRecord.get('record');

            Map<String,Map<String, List<CheckResult__c>>> checkResults = (Map<String,Map<String, List<CheckResult__c>>>) createRecord.get('checkResults');
            CheckResult__c checkResult = checkResults.get('General').get('Personnel')[0];
            checkResult.Scores__c = 5;

            List<CheckResult__c> checkResultsIsRelatedToProduct = (List<CheckResult__c>) createRecord.get('checkResultsIsRelatedToProduct');
            CheckResult__c checkResultTV = checkResultsIsRelatedToProduct[0];
            checkResultTV.Scores__c = 5;

            ConResponse checkListSaveResp = NewInspectorDailyReportController.checkListSave(report.Id, JSON.serialize(new List<CheckResult__c>{checkResult}));
            Map<String, Object> checkListSave = (Map<String, Object>) checkListSaveResp.data;
            List<Ticket__c> openTasks = (List<Ticket__c>) checkListSave.get('ticketOpenInfo');
            for(Ticket__c item : openTasks) {
                if(item.DueDate__c == null) {
                    item.DueDate__c = Date.today().addDays(7);
                    item.AssignedTo__c = floorwalker.Id;
                }
            }

            List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>) createRecord.get('samplingInspections');
            siList.add(new Sampling_Inspection__c(
                Unplanned_Sample__c = 'Yes',
                Product__c = product2.Id,
                Inspection_Date__c = report.Report_Date__c, 
                Shop__c = report.Store__c,
                ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + product2.Id + '_' + floorwalker.Id
            ));
            String ticketOpenJson = JSON.serialize(openTasks);
            String ticketClosedJson = '[]';
            String ticketOpenFilesMapJson = '{}';
            milleage.Report__c = report.Id;
            String mileageRecordJson = JSON.serialize(milleage);
            String checkResultsIsRelatedToProductJson = JSON.serialize(new List<CheckResult__c>{checkResultTV});
            Boolean isSubmit = true;
            String attendanceRemark = '';
            NewInspectorDailyReportController.upsertRecord(JSON.serialize(report), JSON.serialize(siList), ticketOpenJson, ticketClosedJson, ticketOpenFilesMapJson, mileageRecordJson, checkResultsIsRelatedToProductJson, isSubmit, attendancePhotoStreamJson, attendanceRemark);
        }
        Test.stopTest();
    }

    @isTest
    static void testMethod4(){
        getData();
        Daily_Inspection_Report__c report = new Daily_Inspection_Report__c();
        report.Report_Date__c = Date.today();
        report.Store__c = store.Id;
        report.Status__c = 'New';
        report.Inspect_Type__c = 'Locale Inspection';
        report.Contact_Status__c = 'Not start';
        String todayReportJson = JSON.serialize(report);
        report.Report_Date__c = Date.today().addDays(-1);
        report.ownerId = floorwalker.Id;
        insert report;

        List<CheckResult__c> checkResultList = new List<CheckResult__c>();
        CheckResult__c checkResult = new CheckResult__c();
        checkResult.InspectorDailyReport__c = report.Id;
        checkResult.Scores__c = 5;
        checkResult.CheckItem__c = checkItem2.Id;
        checkResultList.add(checkResult);

        CheckResult__c checkResultTV = new CheckResult__c();
        checkResultTV.InspectorDailyReport__c = report.Id;
        checkResultTV.Scores__c = 5;
        checkResultTV.CheckItem__c = checkItem.Id;
        checkResultList.add(checkResultTV);

        upsert checkResultList;

        Sampling_Inspection__c samplingInsp = new Sampling_Inspection__c();
        samplingInsp.Unplanned_Sample__c = 'No';
        samplingInsp.Product__c = product.Id;
        samplingInsp.Inspection_Date__c = report.Report_Date__c;
        samplingInsp.Shop__c = report.Store__c;
        samplingInsp.Sample_Item__c = detail.Id;
        samplingInsp.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + product.Id + '_' + floorwalker.Id;
        samplingInsp.OwnerId = floorwalker.Id;
        insert samplingInsp;

        Test.startTest();
        System.runAs(floorwalker) {
            String currentLatStr = '86.587556';
            String currentLongStr = '29.567932';
            String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';

            // List<Sampling_Inspection__c> siList = new List<Sampling_Inspection__c>();
            // siList.add(new Sampling_Inspection__c(
            //     Unplanned_Sample__c = 'Yes',
            //     Product__c = product2.Id,
            //     Inspection_Date__c = report.Report_Date__c, 
            //     Shop__c = report.Store__c,
            //     ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + product2.Id + '_' + floorwalker.Id
            // ));

            ConResponse addPlanOutProductResp = NewInspectorDailyReportController.addPlanOutProduct(JSON.serialize(report), product2.Id);
            Map<String, Object> addPlanOutProduct = (Map<String, Object>) addPlanOutProductResp.data;
            List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>) addPlanOutProduct.get('samplingInspections');
            String ticketOpenJson = '[]';
            String ticketClosedJson = '[]';
            String ticketOpenFilesMapJson = '{}';
            milleage.Report__c = report.Id;
            String mileageRecordJson = JSON.serialize(milleage);
            String checkResultsIsRelatedToProductJson = JSON.serialize(new List<CheckResult__c>{checkResultTV});
            Boolean isSubmit = true;
            String attendanceRemark = '';
            NewInspectorDailyReportController.upsertRecord(JSON.serialize(report), JSON.serialize(siList), ticketOpenJson, ticketClosedJson, ticketOpenFilesMapJson, mileageRecordJson, checkResultsIsRelatedToProductJson, isSubmit, attendancePhotoStreamJson, attendanceRemark);

            
            NewInspectorDailyReportController.createRecord(todayReportJson, 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
            NewInspectorDailyReportController.delProductLine(todayReportJson, product2.Id);
        }


        Test.stopTest();
    }

    @isTest
    static void testMethod5(){
        getData();
        CheckItem__c checkItem3 = new CheckItem__c();
        checkItem3.RecordTypeId = checkItemRecordTypeId;
        checkItem3.Sales_Region__c = 'Hisense South Africa';
        checkItem3.Description__c = 'test hfaoie';
        checkItem3.Product_Line__c = 'TV';
        checkItem3.Project__c = 'Material';
        checkItem3.Active__c = true;
        checkItem3.HasComment__c = true;
        checkItem3.Require_Comment_Scores__c = '1;2;3;4;5';
        checkItem3.Is_Related_To_Product__c = true;

        CheckItem__c checkItem4 = new CheckItem__c();
        checkItem4.RecordTypeId = checkItemRecordTypeId;
        checkItem4.Sales_Region__c = 'Hisense South Africa';
        checkItem4.Description__c = 'test wuwuu';
        checkItem4.Project__c = 'Personnel';
        checkItem4.Active__c = true;
        insert new List<CheckItem__c> {checkItem3, checkItem4};

        CheckListScope__c checkScope3 = new CheckListScope__c();
        checkScope3.CheckItem__c = checkItem3.Id;
        checkScope3.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope3.Active__c = true;
        checkScope3.Sales_Region__c = 'Hisense South Africa';

        CheckListScope__c checkScope4 = new CheckListScope__c();
        checkScope4.CheckItem__c = checkItem4.Id;
        checkScope4.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope4.Sales_Region__c = 'Hisense South Africa';
        checkScope4.Active__c = true;
        insert new List<CheckListScope__c>{checkScope3, checkScope4};



        Test.startTest();
        System.runAs(floorwalker) {
            String currentLatStr = '86.587556';
            String currentLongStr = '29.567932';
            ConResponse getInitDataResp = NewInspectorDailyReportController.getInitData('', currentLatStr, currentLongStr, '');
            Map<String, Object> getInitData = (Map<String, Object>) getInitDataResp.data;
            Daily_Inspection_Report__c report = (Daily_Inspection_Report__c) getInitData.get('record');

            String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';
            // Locale Inspection
            ConResponse createRecordResp = NewInspectorDailyReportController.createRecord(JSON.serialize(report), 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
            Map<String, Object> createRecord = (Map<String, Object>) createRecordResp.data;
            report = (Daily_Inspection_Report__c) createRecord.get('record');

            String attendanceRemark = '';
            List<CheckResult__c> checkResultsIsRelatedToProduct = (List<CheckResult__c>) createRecord.get('checkResultsIsRelatedToProduct');
            for(CheckResult__c item : checkResultsIsRelatedToProduct) {
                item.Scores__c = 5;
            }

            Map<String,Map<String, List<CheckResult__c>>> checkResults = (Map<String,Map<String, List<CheckResult__c>>>) createRecord.get('checkResults');
            List<CheckResult__c> checkResultList = checkResults.get('General').get('Personnel');
            for(CheckResult__c item : checkResultList) {
                item.Scores__c = 5;
            }
            upsert checkResultList;
            NewInspectorDailyReportController.SubmitReport(report, checkResultsIsRelatedToProduct, attendancePhotoStreamJson, attendanceRemark);

            NewInspectorDailyReportController.getCheckResult(report.Id);
            NewInspectorDailyReportController.addPlanOutProduct(JSON.serialize(report), report.Id);
            NewInspectorDailyReportController.getPickList('', '');
            NewInspectorDailyReportController.getPickList('Task', 'Status');
            NewInspectorDailyReportController.queryProduct(product.Id);
            NewInspectorDailyReportController.checkListGetInitData(report.Id, 'TV', 'Material');

            ConResponse samplingInspectionAddResp = NewInspectorDailyReportController.samplingInspectionAdd(JSON.serialize(report), product2.Id);
            Map<String, Object> samplingInspectionAdd = (Map<String, Object>) samplingInspectionAddResp.data;
            List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>)samplingInspectionAdd.get('samplingInspections');
            for(Sampling_Inspection__c item : siList) {
                if(item.Unplanned_Sample__c == 'Yes') {
                    NewInspectorDailyReportController.samplingInspectionDelete(JSON.serialize(report), item.Id);
                    break;
                }
            }

        }
        Test.stopTest();
    }

}