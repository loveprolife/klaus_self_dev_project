@isTest
public with sharing class PromoterAttendanceRuleTriggerHandlerTest {
    static testMethod void testMethod1(){
        Test.startTest();
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='tttttttttt@noemail.com',
        emailencodingkey='UTF-8', lastname='ltttttt', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='lttttttt@noemail.com');
        INSERT user1;
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
        INSERT shop;
        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,30,00,00);
        par.End_time__c = Time.newInstance(18,30,00,00);
        par.Distance__c = 300;
        par.Time_buffer__c = 30;
        par.Need_Check_Distance__c = true;
        par.Name = '10:00-22:00 Buffer-10min Distance-300m';
        insert par;
        Promoter_Attendance_Rule__c par1 = new Promoter_Attendance_Rule__c();
        par1.Start_time__c = Time.newInstance(8,30,00,00);
        par1.End_time__c = Time.newInstance(17,30,00,00);
        par1.Distance__c = 200;
        par1.Time_buffer__c = 40;
        par1.Need_Check_Distance__c = true;
        par1.Name = '10:00-20:00 Buffer-10min Distance-500m';
        insert par1;
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = user1.Id;
        rp.Promoter_Attendance_Rule__c = par.Id; 
        rp.RecordType__c = '促销员';
        INSERT rp; 
        List<Responsible_Person__c> rpp = [SELECT 
        Id, 
        Promoter_Attendance_Rule__c, 
        Promoter_Attendance_Rule__r.Name,
        Principal__c, 
        Principal__r.Name, 
        Shop_Name__c, 
        Shop_Name__r.Name 
        FROM Responsible_Person__c 
        WHERE Promoter_Attendance_Rule__c = : par.Id];
        par.Start_time__c = Time.newInstance(10,30,00,00);
        par.End_time__c = Time.newInstance(19,30,00,00);
        par.Distance__c = 800;
        par.Time_buffer__c = 50;
        par.Name = '11:00-17:00 Buffer-15min Distance-1000m';
        update par;
        Test.stopTest();
    }
    
}