@isTest
public class StoreSamplingAnalysisControllerTest {
    public StoreSamplingAnalysisControllerTest() {

    }

    @isTest
    static void testMethod1(){
        Account acc = new Account(Name = 'testname');
        insert acc;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Japan';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;
        Product__c pro = new Product__c();
        pro.Name = 'pro';
        pro.RecordTypeId = recordId3;
        pro.Product_Line__c = 'TV';
        INSERT pro;

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

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        sd.Shop__c = shop.Id;
        sd.Is_Add__c = '是';
        sd.ExternalID__c = shop.Id + '0';
        sd.Unplanned_Sample__c = '是';
        sd.Product__c = pro.Id;
        sd.Display_Status__c = '展出';
        INSERT sd;

        Product__c pro1 = new Product__c();
        pro1.Name = 'pro1';
        pro1.RecordTypeId = recordId3;
        pro1.Product_Line__c = 'TV';
        INSERT pro1;

        Sampling_Detail__c sd1 = new Sampling_Detail__c();
        sd1.Sampling_Standard__c = ss.Id;
        sd1.Shop__c = shop.Id;
        sd1.Is_Add__c = '是';
        sd1.ExternalID__c = shop.Id + '1';
        sd1.Unplanned_Sample__c = '否';
        sd1.Product__c = pro1.Id;
        sd1.Display_Status__c = '展出';
        
        INSERT sd1;

        Test.startTest();
        StoreSamplingAnalysisController.initData(shop.Id);
        Test.stopTest();
    }
}