@isTest
public class InspectionShopPlanTriggerTest {
	@isTest
    static void testMethod1(){
        String profileName = 'System Admin';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='TestCX@noemail.com',
        emailencodingkey='UTF-8', lastname='TestCX', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testCX@noemail.com');
        INSERT user1; 
        
		Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2024';
        ispTest.Inspection_Month__c = '8';
        INSERT ispTest;
        
        Test.startTest();
        ispTest.Status__c = 'Approved';
        update ispTest;
        Test.stopTest();
        
    }
}