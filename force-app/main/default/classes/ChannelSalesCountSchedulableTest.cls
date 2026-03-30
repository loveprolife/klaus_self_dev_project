@isTest
public class ChannelSalesCountSchedulableTest {
    @isTest
    static void methodTest1(){

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

        // product
        Product__c productTest = new Product__c();
        productTest.Name = 'NTC-22E';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_Line__c = 'TV';
        productTest.Product_External_Id__c = 'NTC-22E-Returns';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
        Insert productTest;   
        
        // promoter daily report
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  acc.id;
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.today();
        Insert testReport1;

        // daily sales
        Retail_Number__c daily = new Retail_Number__c();
        daily.Shop__c = shop1.id;
        daily.Product__c = productTest.id;
        daily.Number__c = 1;
        daily.Price__c = 199;
        daily.CurrencyIsoCode = 'USD';
        daily.Customer__c = acc.id;
        daily.PromoterDailyReport__c = testReport1.id;
        daily.IsUpload__c = true;
        Insert daily;

        ChannelSalesCountSchedulable test = new ChannelSalesCountSchedulable('Hisense South Africa',2024,05,true);
        SchedulableContext sc;
        test.execute(sc);
    }
}