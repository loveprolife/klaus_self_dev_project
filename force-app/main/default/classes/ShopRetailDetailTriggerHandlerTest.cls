@isTest
public class ShopRetailDetailTriggerHandlerTest {
	@isTest
    static void testMethod1(){
        Account testAcc = new Account();
        testAcc.Name = 'ceshi';
        insert testAcc;
        
        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
       	productTest.Name = 'NTC-0804E-TV';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-0804E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = testAcc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  testAcc.id;
        testReport1.Shop__c = shop1.id;
        //testReport1.ExternalId__c = String.valueOf('%'+parExId);
        //testReport.Name = '测试PromoterShare用';
        Insert testReport1;
        
        Shop_Retail_Detail__c testSRD = new Shop_Retail_Detail__c();
		testSRD.Product__c = productTest.id;
		testSRD.Price__c = 100;
		testSRD.Shop__c = shop1.id;
		testSRD.PromoterDailyReport__c = testReport1.id;   
        insert testSRD;
        
        Test.startTest();
        testSRD.Price__c = 200;
        update testSRD;
        Test.stopTest();
    }
}