@isTest
public class PromoCourtControllerTest {
	@isTest
    static void testPromoController(){
        Account testcust = new Account();
        testcust.Name = 'Hisense';
        testcust.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        Insert testcust;
         
        Account customerTest = new Account();
        customerTest.Name = '测试MarketInsight客户0628';
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试PromoController门店0628(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Market__c testMarket = new Market__c();
        // testMarket.Customer__c =  customerTest.id;
        testMarket.Shop__c = testShop.id;
        //testMarket.Name = '测试marketInsight用';
        Insert testMarket;
        
        PromoCourt__c testPromoCourt1 = new PromoCourt__c();
        //testPromoCourt.Name = '测试类用0628(1)';
        testPromoCourt1.Store__c = testShop.id;
        testPromoCourt1.Customer__c = customerTest.id;
        testPromoCourt1.Market__c = testMarket.id;
        testPromoCourt1.CurrencyIsoCode = 'USD';
        
        PromoCourt__c testPromoCourt2 = new PromoCourt__c();
        //testPromoCourt.Name = '测试类用0628(2)';
        testPromoCourt2.Store__c = testShop.id;
        testPromoCourt2.Customer__c = customerTest.id;
        testPromoCourt2.Market__c = testMarket.id;
        testPromoCourt2.CurrencyIsoCode = 'USD';
        Insert testPromoCourt2;
        
        Map<String,String> recordMap = new Map<String,String>(); 
        recordMap.put('Id',testPromoCourt2.Id);
        recordMap.put('fieldsEdit','true');
        recordMap.put('Store__c',String.valueOf(testShop.id));
        recordMap.put('Customer__c',String.valueOf(customerTest.id));
        recordMap.put('Market__c',String.valueOf(testMarket.id));
        recordMap.put('CurrencyIsoCode','USD');
        
        Map<String,String> recordMap2 = new Map<String,String>(); 
        recordMap2.put('Store__c',String.valueOf(testShop.id));
        recordMap2.put('Customer__c',String.valueOf(customerTest.id));
        recordMap2.put('Market__c',String.valueOf(testMarket.id));
        recordMap2.put('CurrencyIsoCode','USD');
        
		List<Map<String,String>> recordList = new List<Map<String,String>>();
        recordList.add(recordMap);
        String recordDataJson = Json.serialize(recordList);
        
        List<Map<String,String>> recordList2 = new List<Map<String,String>>();
        recordList2.add(recordMap2);
        String recordDataJson2 = Json.serialize(recordList2);
        
        List<String> deleteList = new List<String>();
		deleteList.add(testPromoCourt2.Id);  
        
		Map<String,Object> fileMap = new Map<String,Object>();
        fileMap.put('1',testPromoCourt2);
        String fileMapJson = Json.serialize(fileMap);   
        
        Test.startTest();
        PromoCourtController.getInitData(testMarket.Id);
        PromoCourtController.saveRecord(recordDataJson,deleteList,fileMapJson,testMarket.id);
        PromoCourtController.saveRecord(recordDataJson2,deleteList,fileMapJson,testMarket.id);
        Test.stopTest();
    }
}