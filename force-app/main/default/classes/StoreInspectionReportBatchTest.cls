@isTest
public with sharing class StoreInspectionReportBatchTest {

    @IsTest
    static void method1(){

        profile pf = [SELECT Id FROM profile WHERE Name = 'System Admin' LIMIT 1]; 
        User user1 = new User(alias = '促销员', email='StoreInspectionReport@test.com',
        emailencodingkey='UTF-8', lastname='StoreInspectionReport', languagelocalekey='en_US',
        localesidkey='en_US',profileid = pf.Id, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='StoreInspectionReport@test.com');
        Insert user1; 

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;
        
        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.Shop_Name__c = store.Id;
        rp.Promoter_Attendance_Rule__c = par.Id;
        rp.RecordType__c = '巡店员';
        insert rp;

        Responsible_Person__c rp1 = new Responsible_Person__c();
        rp1.Principal__c = user1.Id;
        rp1.Shop_Name__c = store.Id;
        rp1.Promoter_Attendance_Rule__c = par.Id;
        rp1.RecordType__c = 'Backup Floorwalker';
        insert rp1;
        

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Store__c = store.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'Submitted';
        Insert testDIR;

        Daily_Inspection_Report__c testDIR1 = new Daily_Inspection_Report__c();
        testDIR1.Report_Date__c = System.today().addDays(1);
        testDIR1.Store__c = store.id;
        testDIR1.OwnerId = UserInfo.getUserId();
        testDIR1.Status__c = 'Submitted';
        Insert testDIR1;

        Ticket__c tik = new Ticket__c();
        tik.InspectionReport__c = testDIR.id;
        tik.Store__c = store.id;
        tik.DueDate__c = System.today().addDays(2);
        tik.RecordTypeId = Schema.SObjectType.Ticket__c.getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
        tik.Status__c = 'Open';
        insert tik;

        Ticket__c tik1 = new Ticket__c();
        tik1.InspectionReport__c = testDIR1.id;
        tik1.Store__c = store.id;
        tik1.DueDate__c = System.today().addDays(1);
        tik1.RecordTypeId = Schema.SObjectType.Ticket__c.getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
        tik1.Status__c = 'Open';
        insert tik1;

        
        Ticket__c tik2 = new Ticket__c();
        tik2.InspectionReport__c = testDIR.id;
        tik2.Store__c = store.id;
        tik2.RecordTypeId = Schema.SObjectType.Ticket__c.getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
        tik2.Status__c = 'Closed';
        insert tik2;

        Ticket__c tik3 = new Ticket__c();
        tik3.InspectionReport__c = testDIR1.id;
        tik3.Store__c = store.id;
        tik3.RecordTypeId = Schema.SObjectType.Ticket__c.getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
        tik3.Status__c = 'Closed';
        insert tik3;

        StoreInspectionReportBatch sir = new StoreInspectionReportBatch();
        Database.executeBatch(sir,200);

        StoreInspectionReportBatch sir1 = new StoreInspectionReportBatch(2024, 4);
        Database.executeBatch(sir1,200);
    }
}