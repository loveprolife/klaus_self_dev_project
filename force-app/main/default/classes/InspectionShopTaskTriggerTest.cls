@isTest
public class InspectionShopTaskTriggerTest {
	@isTest
    static void testMethod1(){
		String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '巡店员', email='TestCX@noemail.com',
        emailencodingkey='UTF-8', lastname='TestCX', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testCX@noemail.com');
        INSERT user1;         
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'Approved';
        ispTest.Inspection_Year__c = '2025';
        ispTest.Inspection_Month__c = '2';
        INSERT ispTest;
        System.debug('test ownerId--->'+ispTest.OwnerId);
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        //ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        
        Test.startTest();
        INSERT ist;
        Test.stopTest();
    }
}