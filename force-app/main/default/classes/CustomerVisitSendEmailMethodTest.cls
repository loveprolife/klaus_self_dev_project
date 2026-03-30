@isTest
public class CustomerVisitSendEmailMethodTest{
    @isTest
    static void Test1(){
        Test.startTest();
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator' OR Name = '系统管理员'];
        User user1 = new User(
            Alias = 'admin', 
            Email = 'CustomerVisitSendEmailMethodTest@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'CustomerVisitSendEmailMethodTest@hisensetest.com'
        );
        Database.insert (user1);
        User user2 = new User(
            Alias = 'admin', 
            Email = 'CustomerVisitSendEmailMethodTest2@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'CustomerVisitSendEmailMethodTest2@hisensetest.com'
        );
        Database.insert (user2);
        Account acc1 = new Account(
            Name = 'Test sap1000000', 
            SAP_Customer_Code__c = 'sap1000000', 
            External_Key__c = 'sap1000000', 
            Sales_Region__c = 'salesRegion', 
            Approval_Status__c = 'Approved'
        );
        Database.insert (acc1);

        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc1.id;
        atm.UserId = user1.id;
        Database.insert (atm);
        AccountTeamMember atm2 = new AccountTeamMember();
        atm2.AccountId = acc1.id;
        atm2.UserId = user2.id;
        Database.insert (atm2);

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
        cv.MeetingContent__c = '';
        Database.insert (cv);
        CustomerVisitCloneController.copyCustomerVisit(cv.id);

        CustomerVisitSendEmailInvocableMethod.CustomerVisitSendEmail(new List<String>{ cv.Id });
        Test.stopTest();
    }

}