@isTest
private class CustomerVisitCloneControllerTest {
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
        CustomerVisitCloneController.copyCustomerVisit(cv.id);
        Test.stopTest();

        List<Customer_Visit__c> cvlist = [
            select Id,Name,Visit_Date__c
            from Customer_Visit__c
            where Name ='test001_Copy'
            ];
        System.assertEquals(1, cvlist.size());
        System.assertEquals(null, cvlist[0].Visit_Date__c);
    }
}