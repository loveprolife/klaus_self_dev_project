@isTest
public with sharing class NewResponsiblePersonTriggerHandlerTest {
    static testMethod void testMethod1(){
        
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test123456@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123455', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test1234444@noemail.com');
        INSERT user1;
        
        User user2 = new User(alias = '促销员', email='test22226@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing2225', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test1222244@noemail.com');
        INSERT user2;
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        insert shop;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        shop1.City__c = '北京市';
        shop1.Shop_Center_Location__Latitude__s = 19.4545;
        shop1.Shop_Center_Location__Longitude__s = 56.509;
        insert shop1;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;
        
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c =  testPAR.id;
        INSERT rp; 

        Responsible_Person__c rp1 = new Responsible_Person__c();
        rp1.Shop_Name__c = shop.Id;
        rp1.Principal__c = user1.Id;
        rp1.RecordType__c = '促销员';
        rp1.Promoter_Attendance_Rule__c =  testPAR.id;

        Test.startTest();
		try {
            insert rp1;
            
        } catch (Exception e) {
            
        } 

        rp.Principal__c = userInfo.getUserId();
        update rp;
        Test.stopTest();
    }
}