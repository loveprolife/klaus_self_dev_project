@isTest
public with sharing class ApplicationTriggerHandlerHelperTest {
    @IsTest
    static void CheckInOut(){
        //user
        profile pf = [SELECT Id FROM profile WHERE Name = 'System Admin' LIMIT 1]; 
        User user1 = new User(alias = '促销员', email='TestCX111aaa@noemail.com',
        emailencodingkey='UTF-8', lastname='TestCX111aaa', languagelocalekey='en_US',
        localesidkey='en_US',profileid = pf.Id, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testCX111aaa@noemail.com',ManagerId=UserInfo.getUserId());
        Insert user1; 

        //account
        Account acc = new Account();
        acc.Name = 'test';
        Insert acc;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        //Promoter_Attendance_Rule__c
        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.Shop_Name__c = shop1.Id;
        rp.Promoter_Attendance_Rule__c = par.Id;
        insert rp;
        

        String recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Additional Check-In/Out').getRecordTypeId();
        Application__c app = new Application__c();
        app.RecordTypeId = recordTypeId;
        app.CheckDate__c = Date.newInstance(Date.today().year(),Date.today().month(),Date.today().day());
        app.Reason__c = 'test';
        app.CheckInStoreName__c = shop1.Id;
        app.RefillCheckInTime__c = Time.newInstance(12,0,0,0);
        app.CheckOutStoreName__c = shop1.Id;
        app.RefillCheckOutTime__c = Time.newInstance(18,0,0,0);
        app.FirstApprover__c = user1.Id;
        Test.startTest();
        // System.runAs(user1){
            insert app;
            app.Status__c = 'Approved';
            update app;
        // }
        
        Test.stopTest();
        
    }
    
}