@isTest
public with sharing class StoreMapControllerTest {

    @IsTest
    static void method1(){
        
        Shop__c shop = new Shop__c();
        shop.Name = 'test';
        shop.City__c = '广州市';
        shop.Address1__c = '天河区';
        insert shop;

        
        shop.Shop_Center_Location__Longitude__s = 1.00001;
        shop.Shop_Center_Location__Latitude__s = 1.00001;
        update shop;
        System.debug('store insert');

        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Date__c = System.today();
        dir.Store__c = shop.Id;
        dir.Status__c = 'Submitted';
        insert dir;
        System.debug('Daily_Inspection_Report__c insert');
        
        Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
        pdr.Shop__c = shop.id;
        pdr.Report_Date__c = System.today();
        insert pdr;
        System.debug('Promoter_Daily_Report__c insert');

        Retail_Number__c rn = new Retail_Number__c();
        rn.Shop__c = shop.Id;
        rn.Price__c = 100;
        rn.Number__c = 1;
        rn.Status__c = 'Submitted';
        rn.PromoterDailyReport__c = pdr.Id;
        insert rn;
        System.debug('Retail_Number__c insert');

        StoreMapController.getInitData('1.00002','1.00002');
        StoreMapController.fetchLookupData('t','Shop__c','1.00002','1.00002',1,1);

        CurrencyRateHelper.getConversionRate('','');
        CurrencyRateHelper.getConversionRate('CNY','USD');
        
    }
}