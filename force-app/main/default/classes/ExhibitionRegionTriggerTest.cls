@isTest
private class ExhibitionRegionTriggerTest {
    static testMethod void testMethod1() {
    	String profileName  = '展会 展务组';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        INSERT user1;

        Exhibition_Region_Owner__c e = new Exhibition_Region_Owner__c(Name = '测试用户', Email__c = 'TestTom@noemail.com');
        INSERT e;
        e.Name = 'Test Name';
        UPDATE e;

    }
}