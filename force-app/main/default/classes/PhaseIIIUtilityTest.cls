@isTest
public class PhaseIIIUtilityTest {
	@isTest
    Static void testMethod1(){
        String profileName = 'System Admin'; 
        List<profile> listpro = [SELECT Id FROM profile WHERE Name = :profileName];
        Id profileId = listpro[0].Id;
        User user1 = new User(alias = '促销员', email='test1230000000000@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123000000000000000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, Country__c='Chile',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test123000000@noemail.com');
        INSERT user1;
        
        User user2 = new User(alias = '促销员', email='test12334300@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing14300000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, Country__c='Chile',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test343000@noemail.com');
        INSERT user2;
        
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.SAP_Customer_Code__c = '123456';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        testShop.Sales_Region__c = 'Hisense Chile';
        Insert testShop;
        
        Market__c testMarket = new Market__c();
        testMarket.Shop__c = testShop.id;
        testMarket.OwnerId = user1.id;
        testMarket.Report_Date__c = System.today();
        testMarket.Status__c = 'New';
        Insert testMarket;
        
        Test.startTest();
        System.runAs(user1){
            //PhaseIIIUtility testPhaseIIIUtility = new PhaseIIIUtility();
            PhaseIIIUtility.isPhaseIIIUser();
            PhaseIIIUtility.isPhaseIIIData(testMarket.id);
            PhaseIIIUtility.isPhaseUser();
            PhaseIIIUtility.isPhaseData(testMarket.id);
            PhaseIIIUtility.isChile(testShop);
            PhaseIIIUtility.isIndonesia(testShop);
            PhaseIIIUtility.isSouthAfrica(testShop);
            PhaseIIIUtility.isPhaseIIIUserUpdate('Hisense Chile');
            PhaseIIIUtility.isPhaseUserUpdate('Hisense Chile');
        }
        Test.stopTest();
    }
}