@isTest
private class SamplingDetailChangeStandardsBatchTest {
    static testMethod void testHandler() {
        Account acc = new Account();
        acc.Name = 'KS';
        INSERT acc;

        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;

        Product__c pro = new Product__c();
        pro.name = 'name1';
        pro.Level__c = 'A';
        pro.RecordTypeId = recordId3;
        INSERT pro;

        Product__c pro1 = new Product__c();
        pro1.name = 'name2';
        pro1.Level__c = 'A';
        pro1.RecordTypeId = recordId3;
        INSERT pro1;

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

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Grid__c = gird1.id;
        shop1.City__c = '青岛市';
        INSERT shop1;

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
        ss.Product__c = pro.id;
        ss.ExternalID__c =  acc.Id + '-' + pro.id;
        ss.Level__c = 'A'; 
        INSERT ss;

        Sampling_Standard__c ss1 = new Sampling_Standard__c();
        ss1.Sampling_Mapping__c = sm.Id;
        ss1.Channel_Name__c = acc.Id;
        ss1.Status__c = 'True';
        ss1.Is_Add_ByReport__c = true;
        ss1.Product__c = pro1.id;
        ss1.ExternalID__c =  acc.Id + '-' + pro.id;
        INSERT ss1;

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        sd.Product__c = pro.id;
        sd.Shop__c = shop.id;
        INSERT sd;

        Sampling_Detail__c sd1 = new Sampling_Detail__c();
        sd1.Sampling_Standard__c = ss.Id;
        sd1.Product__c = pro.id;
        sd1.Shop__c = shop1.id;
        INSERT sd1;

        test.startTest();
        SamplingDetailChangeStandardsBatch sdcsb  = new SamplingDetailChangeStandardsBatch(ss.id); 
        Database.executeBatch(sdcsb, 200);
        test.stopTest();
    }
}