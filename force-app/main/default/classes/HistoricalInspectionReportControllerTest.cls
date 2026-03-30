@isTest
public with sharing class HistoricalInspectionReportControllerTest {
    
    @IsTest
    static void method1(){
        Shop__c shop = new Shop__c();
        shop.Name = 'test';
        shop.City__c = '广州市';
        shop.Address1__c = '天河区';
        insert shop;

        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Date__c = Date.valueOf('2020-10-1');
        dir.Store__c = shop.Id;
        dir.Status__c = 'Submitted';
        insert dir;

        CheckItem__c ci = new CheckItem__c();
		ci.Description__c = 'old';
		ci.Description_CN__c = 'old';
		ci.Description_EN__c = 'old';
		// ci.Description_Filling_Language__c = 'en_US';
		ci.Active__c = true;
        ci.BussinessArea__c = 'Chile';
        ci.MaximumScore__c = '5';
        ci.Product_Line__c = 'TV';
        ci.Project__c = 'Booth and image';
        ci.HasFile__c = false;
        ci.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('Chile').getRecordTypeId();
        ci.OrderNumber__c = 10;
        Insert ci;

        CheckResult__c cr = new CheckResult__c();
        cr.CheckItem__c = ci.Id;
        cr.Max_Scores__c = 5;
        cr.Scores__c = 2;
        cr.Comments__c = '测试CR用';
        cr.Status__c = 'Submitted';
        cr.InspectorDailyReport__c = dir.id;
        Insert cr;

        HistoricalInspectionReportController.init(UserInfo.getUserId(), '2020-11-01', shop.Id);
    }
}