@isTest
public class CustomerVisitPrintPDFControllerTest {
    static testMethod void testMethod1() {
    	Test.startTest();

        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);

        Contact con = new Contact();
        con.lastname = '111';
        con.accountId = acc1.Id;
        con.Email = '888@0098.com';
        Database.insert(con);

        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        u.username = 'HisenseSSORegHandlerTest@salesforce.com';
        u.email = 'HisenseSSORegHandlerTest@salesforce.com';
        u.lastName = 'HisenseSSORegHandlerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.HisenseSSOName__c = 'testId';
        insert u;

        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'test001';
        cv.Customer__c = acc1.id;
        cv.Visit_Category__c = '';
        cv.Visit_Date__c = Date.today();
        cv.Sales_Expected_Remind_Date__c = Date.today();
        cv.Place__c = '';
        cv.Visit_Purpose__c = '';
        cv.Status__c = '';
        cv.Achivement__c = '';
        cv.Visit_Matter__c = '';
        cv.Meeting_Minutes__c = '';
        Database.insert(cv);

        Visit_Participant__c vp = new Visit_Participant__c();
        vp.Customer_Participant__c = con.Id;
        vp.Hisense_Participant__c = u.Id;
        vp.Hisense_Participant_Position__c = '';
        vp.Customer_Visit__c = cv.id;
        Database.insert(vp);

        ApexPages.currentPage().getParameters().put('Id',cv.ID);
    	CustomerVisitPrintPDFController cvp = new CustomerVisitPrintPDFController();
        cvp.competitorTrends = '';
        cvp.hisenseClientOperatingConditions = '';
        cvp.hisenseStrategicProgramProgress = '';
        cvp.problemsToBeSolvedByHisense = '';
        cvp.StatusQuoOfIndustry = '';
        cvp.hisenseOtherIssues = '';
        cvp.order = '';
        cvp.inventory = '';
        cvp.promotion = '';
        cvp.SKUDisplay = '';
        cvp.productsRecommendation = '';
        cvp.rebateAndSupport = '';
        
        Test.stopTest();
    }
}