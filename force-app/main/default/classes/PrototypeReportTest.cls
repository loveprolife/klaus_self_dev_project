@isTest
public class PrototypeReportTest {
    @isTest
    static void test1() {
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;

        User user = new User(alias = 'Admin34', email='PrototypeReportTest@noemail.com',
        emailencodingkey='UTF-8', lastname='PrototypeReportTest', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='PrototypeReportTest@noemail.com');
        INSERT user;

        User user1 = new User(alias = 'Admin34', email='PrototypeReportTest1@noemail.com',
        emailencodingkey='UTF-8', lastname='PrototypeReportTest1', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='PrototypeReportTest1@noemail.com');
        INSERT user1;

        Account acc = new Account(
                            Name = 'testname');
        insert acc;   
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Indonesia';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop.Id;
        INSERT rp; 

        Responsible_Person__c rp1 = new Responsible_Person__c();
        rp1.Principal__c = user1.Id;
        rp1.RecordType__c = '促销员';
        rp1.Shop_Name__c = shop.Id;
        INSERT rp1; 

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
        ss.Is_Added__c = '是';
        ss.Level__c = 'A';
        INSERT ss;


        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'RegionalProduct'][0].Id;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.OwnerId = user.Id;
        pro.RecordTypeId = recordId3;
        pro.sales_region__c = 'Hisense Indonesia';
        INSERT pro;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  acc.id;
        testReport1.Shop__c = shop.id;
        testReport1.Report_Date__c = Date.today();
        Database.insert(testReport1);

        Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        testReport2.Customer__c =  acc.id;
        testReport2.Shop__c = shop.id;
        testReport2.Report_Date__c = Date.today().addDays(1);
        Database.insert(testReport2);

        Retail_Number__c rm = new Retail_Number__c();
        rm.Shop__c = shop.id;
        rm.Product__c = pro.id;
        rm.Number__c = 1;
        rm.Price__c = 199;
        rm.CurrencyIsoCode = 'USD';
        rm.Customer__c = acc.id;
        rm.PromoterDailyReport__c = testReport1.id;
        rm.IsUpload__c = true;
        Database.insert(rm);

        Retail_Number__c rm1 = new Retail_Number__c();
        rm1.Shop__c = shop.id;
        rm1.Product__c = pro.id;
        rm1.Number__c = 100;
        rm1.Price__c = 199;
        rm1.CurrencyIsoCode = 'USD';
        rm1.Customer__c = acc.id;
        rm1.PromoterDailyReport__c = testReport2.id;
        rm1.IsUpload__c = true;
        Database.insert(rm1);

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        sd.Shop__c = shop.Id;
        sd.Is_Add__c = '是';
        sd.Product__c = pro.id;
        INSERT sd;

        Sampling_Detail_Display_Time__c sddt = new Sampling_Detail_Display_Time__c();
        sddt.Sampling_Detail__c = sd.Id;
        sddt.Hidden_Time__c = System.now().addMonths(-3);
        sddt.Display_Time__c = System.now().addMonths(-3).addDays(1);
        INSERT sddt;

        Sampling_Detail_Display_Time__c sddt1 = new Sampling_Detail_Display_Time__c();
        sddt1.Sampling_Detail__c = sd.Id;
        sddt1.Hidden_Time__c = System.now();
        sddt1.Display_Time__c = System.now().addMonths(-1).addDays(1);
        INSERT sddt1;

        Sampling_Detail_Display_Time__c sddt2 = new Sampling_Detail_Display_Time__c();
        sddt2.Sampling_Detail__c = sd.Id;
        sddt2.Hidden_Time__c = System.now();
        sddt2.Display_Time__c = System.now();
        INSERT sddt2;

        PrototypeReportBatch pr = new PrototypeReportBatch();
        Database.executeBatch(pr,200);

        PrototypeReportDailySalesBatch prds = new PrototypeReportDailySalesBatch();
        Database.executeBatch(prds,100);

        Prototype_Report__c pr11 = new Prototype_Report__c();
        pr11.Sampling_Detail__c = sd.id;
        INSERT pr11;

        PrototypeReportDeleteBatch prd = new PrototypeReportDeleteBatch();
        Database.executeBatch(prd,200);
    }
}