/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
private class CustomerVisitTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'Hisense Japan',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' OR Name = '系统管理员'];
        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);
        User user2 = new User(
            Alias = 'admin', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user2);
        User user3 = new User(
            Alias = 'admin', Email='systemadmin3@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin3@hisensetest.com'
        );
        Database.insert(user3);
        User user4 = new User(
            Alias = 'admin', Email='systemadmin4@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin4@hisensetest.com'
        );
        Database.insert(user4);
        User user5 = new User(
            Alias = 'admin', Email='systemadmin5@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin5@hisensetest.com'
        );
        Database.insert(user5);
        User user6 = new User(
            Alias = 'admin', Email='systemadmin6@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin6@hisensetest.com'
        );
        Database.insert(user6);

        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc1.id;
        atm.UserId = user1.id;
        Database.insert(atm);
        AccountTeamMember atm2 = new AccountTeamMember();
        atm2.AccountId = acc1.id;
        atm2.UserId = user2.id;
        Database.insert(atm2);
        AccountTeamMember atm3 = new AccountTeamMember();
        atm3.AccountId = acc1.id;
        atm3.UserId = user3.id;
        Database.insert(atm3);
        AccountTeamMember atm4 = new AccountTeamMember();
        atm4.AccountId = acc1.id;
        atm4.UserId = user4.id;
        Database.insert(atm4);
        AccountTeamMember atm5 = new AccountTeamMember();
        atm5.AccountId = acc1.id;
        atm5.UserId = user5.id;
        Database.insert(atm5);
        AccountTeamMember atm6 = new AccountTeamMember();
        atm6.AccountId = acc1.id;
        atm6.UserId = user6.id;
        Database.insert(atm6);
        
        Customer_Visit__c cv = new Customer_Visit__c();
        cv.Name = 'test001';
        cv.Customer__c = acc1.id;
        cv.Visit_Category__c = 'Customer Company';
        cv.Visit_Date__c = Date.today().addDays(3);
        cv.Sales_Expected_Remind_Date__c = Date.today().addDays(2);
        cv.Place__c = 'Beijing';
        cv.Visit_Purpose__c = '';
        cv.Status__c = 'Not Started';
        cv.Approval_Status__c = 'Draft';
        cv.Achivement__c = '';
        cv.Visit_Matter__c = '';
        cv.Meeting_Minutes__c = '';
        Database.insert(cv);
        Customer_Visit__c cv1 = new Customer_Visit__c();
        cv1.Name = 'test002';
        cv1.Customer__c = acc1.id;
        cv1.Visit_Category__c = 'Customer Company';
        cv1.Sales_Expected_Remind_Date__c = Date.today().addDays(2);
        cv1.Place__c = 'Beijing';
        cv1.Visit_Purpose__c = '';
        cv1.Status__c = 'Not Started';
        cv1.Approval_Status__c = 'Draft';
        cv1.Achivement__c = '';
        cv1.Visit_Matter__c = '';
        cv1.Meeting_Minutes__c = '';
        Database.insert(cv1);
        Customer_Visit__c cv2 = new Customer_Visit__c();
        cv2.Name = 'test003';
        cv2.Customer__c = acc1.id;
        cv2.Visit_Category__c = 'Customer Company';
        cv2.Sales_Expected_Remind_Date__c = Date.today().addDays(2);
        cv2.Place__c = 'Beijing';
        cv2.Visit_Purpose__c = '';
        cv2.Status__c = 'Not Started';
        cv2.Achivement__c = '';
        cv2.Visit_Matter__c = '';
        cv2.Meeting_Minutes__c = '';
        cv2.Visit_Date__c = Date.today();
        Database.insert(cv2);
        Event e = new Event();
        e.Customer_Visit__c = cv2.id;
        e.Customer__c = acc1.id;
        e.OwnerId = user1.id;
        e.StartDateTime = Date.today();
        e.EndDateTime = Date.today();
        Database.insert(e);

        Customer_Visit__c cv3 = new Customer_Visit__c();
        cv3.Name = 'test004';
        cv3.Customer__c = acc1.id;
        cv3.Visit_Category__c = 'Customer Company';
        cv3.Sales_Expected_Remind_Date__c = Date.today().addDays(2);
        cv3.Place__c = 'Beijing';
        cv3.Visit_Purpose__c = '';
        cv3.Status__c = 'Not Started';
        cv3.Achivement__c = '';
        cv3.Visit_Matter__c = '';
        cv3.Meeting_Minutes__c = '';
        Database.insert(cv3);
        Customer_Visit__c cv4 = new Customer_Visit__c();
        cv4.Name = 'test005';
        cv4.Customer__c = acc1.id;
        cv4.Visit_Category__c = 'Customer Company';
        cv4.Sales_Expected_Remind_Date__c = Date.today().addDays(2);
        cv4.Place__c = 'Beijing';
        cv4.Visit_Purpose__c = '';
        cv4.Status__c = 'Completed';
        cv4.Achivement__c = '';
        cv4.Visit_Matter__c = '';
        cv4.Meeting_Minutes__c = '';
        cv4.isSendEmail__c = true;
        Database.insert(cv4);
        CustomerVisitCloneController.copyCustomerVisit(cv.id);
        List<Customer_Visit__c> cvlist = [
            select Id,Name,Visit_Date__c
            from Customer_Visit__c
            where Name ='test001_Copy'
            ];
        System.assertEquals(1, cvlist.size());
        System.assertEquals(null, cvlist[0].Visit_Date__c);
        Database.update(cvlist);

        cv.Visit_Category__c = 'Telephone';
        cv.Visit_Date__c = Date.today().addDays(5);
        cv.Approval_Status__c = 'Submitted';
        cv1.Status__c = 'Completed';
        Database.update(cv);
        cv1.Visit_Category__c = 'Telephone';
        cv1.Approval_Status__c = 'Approved';
        cv1.Status__c = 'Completed';
        Database.update(cv1);
        cv3.Visit_Category__c = 'Telephone';
        cv3.Status__c = 'Completed';
        Database.update(cv3);
        cv2.Visit_Category__c = 'Telephone';
        cv2.Status__c = 'Completed';
        cv2.isSendEmail__c = true;
        Database.update(cv2);

        Database.delete(cv);
        Test.stopTest();

    }
}