@isTest
public with sharing class MDGNewSubAccountControllerTest {

    @isTest
    static void methodTest0(){
        
        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        String profileName = 'Canada Sales Manager';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(
            alias = 'test', 
            email='DailySalesUploadControllerTest@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='canadaSalesTest', 
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = profileId,
            country='Canada',
            IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='DailySalesUploadControllerTest@noemail.com',
            Sales_Region__c='Hisense Canada');
        INSERT user1;
        
        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.RecordTypeId = customerRTId;
        acc.Sales_Region__c = 'Hisense Canada';
        acc.Guarantor_Country_Code__c = 'CA';
        acc.Company_Registration_Number__c = '1001001';
        Insert acc;
        
        Test.startTest();
        System.runAs(user1) {
            MDGNewSubAccountController.getParentFields(acc.Id);
            MDGNewSubAccountController.getRecordTypeIdByDeveloperName('customer');
        }
        Test.stopTest();
    }

}