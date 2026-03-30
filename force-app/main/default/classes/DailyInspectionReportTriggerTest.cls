@isTest
public class DailyInspectionReportTriggerTest {
	@isTest
    static void testMethod1(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '促销员', email='TestC43423@noemail.com',
        emailencodingkey='UTF-8', lastname='TestC43423', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestC43423@noemail.com');
        INSERT user1;
        
        Account acc = new Account();
        acc.Name = 'ceshis';
        insert acc;
        
        Shop__c shop4 = new Shop__c();
        shop4.Account__c = acc.Id;
        shop4.Shop_Level__c = 'A';
        shop4.Name = '测试店444';
        INSERT shop4;
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Date.today().year() + '';
        ispTest.Inspection_Month__c = Date.today().month() + '';
        INSERT ispTest;
        
		Daily_Inspection_Report__c testDIR6 = new Daily_Inspection_Report__c();
        testDIR6.Report_Date__c = System.today();
        testDIR6.Inspection_Shop_Plan__c = ispTest.id;
        testDIR6.Store__c = shop4.id;
        testDIR6.OwnerId = UserInfo.getUserId();
        testDIR6.Status__c = 'New';
        testDIR6.NeedCheckIn__c = true;
        Insert testDIR6;
        
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
        
        //test DailyInspectionReportTriggerHandHelper
        CheckResult__c testCR3 = new CheckResult__c();
		testCR3.CheckItem__c = testCI.Id;
        testCR3.Scores__c = 2;
        testCR3.Comments__c = '测试CR用';
        testCR3.Status__c = 'Draft';
        testCR3.InspectorDailyReport__c = testDIR6.id;
        Insert testCR3;
        
        Test.startTest();
        testDIR6.Status__c = 'Submitted';
        update testDIR6;
		Test.stopTest();
    }
}