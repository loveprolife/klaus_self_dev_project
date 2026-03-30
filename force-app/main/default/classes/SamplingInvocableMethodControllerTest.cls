@isTest
public without sharing class SamplingInvocableMethodControllerTest{
    @isTest
    static void testMethod1(){
        String profileName = '巡店员';
        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = :profileName][0].Id;
        User user1 = new User(
            alias = '巡店员', 
            email = 'testfff@noemail.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'testfff', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testfff@noemail.com'
        );
        insert user1;

        Account acc = new Account();
        acc.Name = 'KS';
        insert acc;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        insert pro;

        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c = 'J01-J001';
        insert gird1;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        insert shop;

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        insert sm;

        Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        insert ss;

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        insert sd;

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        insert ist;

        Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
        inspectionReport.Report_Date__c = System.today();
        inspectionReport.OwnerId = user1.Id;
        inspectionReport.Store__c = shop.Id;
        insert inspectionReport;

        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        si.Inspection_Report__c = inspectionReport.Id;
        si.Product__c = pro.Id;
        si.Shop__c = shop.Id;
        insert si;

        SamplingInvocableMethodController.relevanceSampling(new List<String>{ inspectionReport.Id });
    }

}