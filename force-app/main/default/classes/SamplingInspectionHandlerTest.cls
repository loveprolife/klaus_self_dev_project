@isTest
private class SamplingInspectionHandlerTest {
    static testMethod void testHandler() {
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='testfff@noemail.com',
        emailencodingkey='UTF-8', lastname='testfff', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testfff@noemail.com');
        INSERT user1;

        Account acc = new Account();
        acc.Name = 'KS';
        INSERT acc;
        
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        INSERT pro;
        
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        INSERT shop;

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        INSERT sm;

        Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        INSERT ss; 

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        INSERT sd; 

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        INSERT ist;

        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        test.startTest();
        INSERT si;
        test.stopTest();
    }
}