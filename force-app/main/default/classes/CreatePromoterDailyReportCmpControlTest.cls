@isTest
public with sharing class CreatePromoterDailyReportCmpControlTest {
	@isTest
    static void testMethod1(){
        String profileName = 'System Admin'; 
        List<profile> listpro = [SELECT Id FROM profile WHERE Name = :profileName];
        Id profileId = listpro[0].Id;
        User user1 = new User(alias = '促销员', email='test88888000@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing1277770000000000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, Country__c='Chile',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test99900000@noemail.com');
        INSERT user1;
        
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Market__c testMarket = new Market__c();
        testMarket.Shop__c = testShop.id;
        testMarket.OwnerId = user1.id;
        testMarket.Report_Date__c = System.today();
        testMarket.Status__c = 'New';
        Insert testMarket;
        
        Test.startTest();
        CreatePromoterDailyReportCmpController.isPhaseIIIUser(testMarket.Id, 'Hisense Chile');
        CreatePromoterDailyReportCmpController.isPhaseIIIUser(null, '');
        CreatePromoterDailyReportCmpController.isPhaseIIIIUser(testMarket.Id, 'Hisense Chile');
        CreatePromoterDailyReportCmpController.isPhaseIIIIUser(null, '');
        CreatePromoterDailyReportCmpController.getReportType(testMarket.Id);
        CreatePromoterDailyReportCmpController.getSalesRegion();
    	Test.stopTest();
    }
}