@isTest
public class NewInspectionDailyReportPageTest {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @isTest
    static void testMethod1(){
        String recordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByDeveloperName().get('International').getRecordTypeId();
        System.debug('wwwrecordTypeId:' + recordTypeId);

        // 仅配置了总部的检查项有该ItemType
        String currentLatStr = '86.587556';
        String currentLongStr = '29.567932';

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        CheckItem__c item3 = new CheckItem__c();
        item3.RecordTypeId = recordTypeId;
        // item3.Sales_Region__c = currentUser.Sales_Region__c;	
        item3.Item_Type__c = 'Prototype';
        item3.Description__c = 'XXXmmmm';
        item3.Check_Item_Type__c = '巡店';
        item3.Question_Type__c = 'Yes/No';
        item3.OrderNumber__c = 3;
        insert item3;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Sales_Region__c = 'Hisense Australia';	
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90999';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = TIme.newInstance(18, 0, 0, 0);
        testPAR.Name = 'testPAR2';
        insert testPAR;

        // Responsible_Person__c rp = new Responsible_Person__c();
        // rp.Principal__c = UserInfo.getUserId();
        // rp.RecordType__c = '巡店员';
        // rp.Shop_Name__c = shop1.Id;
        // rp.Promoter_Attendance_Rule__c = testPAR.id;
        // INSERT rp;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = currentUser.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2025';
        ispTest.Inspection_Month__c = '09';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Inspection_Product_Item__c testDIRItem = new Inspection_Product_Item__c();
        testDIRItem.Inspection_Report__c = testDIR.Id;
        testDIRItem.Product_Line__c = 'TV';
        Insert testDIRItem;

        Store_Product_Line__c spl = new Store_Product_Line__c();
        spl.Store__c = shop1.Id;
        spl.Product_Line__c = 'TV';
        spl.Entering_Status__c = 'Entered';
        Insert spl;

        String testDIRJson = JSON.serialize(testDIR);
        
        currentUser.Sales_Region__c = 'Hisense International';
        update currentUser;

        String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';

        test.startTest();
        NewInspectionDailyReportPageController.createRecord(testDIRJson, 'Locale Inspection', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);
        NewInspectionDailyReportPageController.createRecord(testDIRJson, 'From Photo', attendancePhotoStreamJson, 'attendanceRemark', currentLatStr, currentLongStr);

        NewInspectionDailyReportPageController.upsertProductLineStatus(testDIRItem.id, 'Start', 'TV');

        NewInspectionDailyReportPageController.submitInspectionProductItem(testDIRItem.id);

        NewInspectionDailyReportPageController.getProductLineCheckItemNumber(testDIRItem.id, 'TV', shop1.id);
        NewInspectionDailyReportPageController.changeInspectionProductItem(testDIRItem.Id, 'Unite');
        NewInspectionDailyReportPageController.upsertPatrolMode(testDIRItem.Id, 'Unite');
        NewInspectionDailyReportPageController.gabige();
        test.stopTest();
    }

    @isTest
    static void testMethod2(){
        String recordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByDeveloperName().get('International').getRecordTypeId();
        System.debug('wwwrecordTypeId:' + recordTypeId);
        String currentLatStr = '86.587556';
        String currentLongStr = '29.567932';

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        CheckItem__c item3 = new CheckItem__c();
        item3.RecordTypeId = recordTypeId;
        item3.Item_Type__c = 'Prototype';
        item3.Description__c = 'XXXmmmm';
        // item3.Question_Type__c = 'Yes/No';
        item3.Check_Item_Type__c = '巡店';
        item3.OrderNumber__c = 3;

        item3.Sales_Region__c = 'Hisense International';	
        insert item3;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Sales_Region__c = 'Hisense Australia';	
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90999';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

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

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = currentUser.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2025';
        ispTest.Inspection_Month__c = '09';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Inspection_Product_Item__c testDIRItem = new Inspection_Product_Item__c();
        testDIRItem.Inspection_Report__c = testDIR.Id;
        testDIRItem.Product_Line__c = 'TV';
        Insert testDIRItem;

        Store_Product_Line__c spl = new Store_Product_Line__c();
        spl.Store__c = shop1.Id;
        spl.Product_Line__c = 'TV';
        spl.Entering_Status__c = 'Entered';
        Insert spl;

        currentUser.Sales_Region__c = 'Hisense USA';
        update currentUser;

        String testDIRJson = JSON.serialize(testDIR);

        String attendancePhotoStreamJson = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';

        test.startTest();
        NewInspectionDailyReportPageController.getProductLineCheckItemNumber(testDIRItem.id, 'TV', shop1.id);
        NewInspectionDailyReportPageController.changeInspectionProductItem(testDIRItem.Id, 'Unite');
        test.stopTest();
    }
}