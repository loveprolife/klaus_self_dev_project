/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-02-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class WeekResearchHandlerTest {
    static testMethod void testTriggerMethod(){
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

		Week_Research__c wr = new Week_Research__c();
        //wr.Start_Date__c = Date.valueOf('2022-02-07');
        //wr.End_Date__c = Date.valueOf('2022-02-13') ;
        wr.DuplicateRemark__c = 'a1c0T000000Xh97QAC_0050T0000023XhXQAU_true';
        wr.IsActive__c  = True;
        wr.Shop__c = shop.id;
		test.startTest();
        INSERT wr;
		test.stopTest();  
    }

    static testMethod void testTriggerMethod1(){
        Test.startTest();
        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;

        User user2 = new User(alias = '巡店员', email='testabs@noemail.com',
        emailencodingkey='UTF-8', lastname='Testingabs', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testabs@noemail.com');
        INSERT user2;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

		Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        wr.Promoter__c = user1.id;
        INSERT wr;

        wr.Promoter__c = user2.id;
        UPDATE wr;


		test.stopTest();  
    }

}