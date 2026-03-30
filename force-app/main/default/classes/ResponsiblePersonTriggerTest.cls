/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-15-2022
 * @last modified by  : ryshen@deloitte.com.cn
 **/
@isTest
private class ResponsiblePersonTriggerTest{
    static testMethod void testHandler(){
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        String profileName = '巡店员';
        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :profileName][0].Id;
        User user1 = new User(
            alias = '巡店员', 
            email = 'test123@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing123', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'wwtest123@noemail.com'
        );


        User user2 = new User(
            alias = '巡店员', 
            email = 'test1234@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing1234', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'wwtest1234@noemail.com'
        );

        User user3 = new User(
            alias = '巡店员', 
            email = 'test12345@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing12345', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'wwtest12345@noemail.com'
        );

        insert new List<User>{ user1, user2, user3 };


        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';

        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'B';
        shop2.Name = 'Homeplus本石町店1';

        insert new List<Shop__c>{ shop1, shop2 };

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.UserEmail__c = 'test123@noemail.com';
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;

        Responsible_Person__c rp1 = new Responsible_Person__c();
        rp1.Principal__c = user2.Id;
        rp1.RecordType__c = '巡店员';
        rp1.Shop_Name__c = shop2.Id;

        insert new List<Responsible_Person__c>{ rp, rp1 };

        // Responsible_Person__c rp2 = new Responsible_Person__c();
        // rp2.UserEmail__c = 'test12345@noemail.com';
        // rp2.RecordType__c = '巡店员';
        // rp2.Shop_Name__c = shop1.Id;
        // INSERT rp2;

        rp.Principal__c = user3.id;
        update rP;

        rp.UserEmail__c = 'test1234@noemail.com';
        update rP;

        delete rp1;

        Test.stopTest();
    }

}