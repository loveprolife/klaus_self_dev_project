@isTest
public class CustomerVisitPrintPDFButtonCTLTest {
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
        CustomerVisitPrintPDFButtonController.getCustomerVisit(cv.id);

        Customer_Visit_Detail__c cvd = new Customer_Visit_Detail__c();
        cvd.Customer_Visit_Lookup__c = cv.id;
        cvd.Attend_From_Customer__c = '1';
        cvd.Attend_From_Hisense__c = '1';
        cvd.Representative_From_Customer__c = '1';
        cvd.Representative_From_Hisense__c = '1';
        Database.insert(cvd);
        CustomerVisitPrintPDFButtonController.getVisitDetail(cv.id);
        Test.stopTest();
    }
}