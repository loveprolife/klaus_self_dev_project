@isTest
public class PromoterShareControllerTest {
	@isTest
    static void testPromoterController(){
		Account testcustomer = new Account();
        testcustomer.Name = 'Hisense';
        testcustomer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        Insert testcustomer;
         
        Account customerTest = new Account();
        customerTest.Name = '测试PromoterShare客户0628';
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试PromoterShare门店0628(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Market__c testMarket = new Market__c();
        // testMarket.Customer__c =  customerTest.id;
        testMarket.Shop__c = testShop.id;
        //testMarket.Name = '测试PromoterShare用';
        Insert testMarket;
        
        PromoterShare__c testPromoterShare = new PromoterShare__c();
        testPromoterShare.Store__c = testShop.Id;
        testPromoterShare.Customer__c = customerTest.id;
        testPromoterShare.Market__c = testMarket.id;
        testPromoterShare.ProductLine__c = 'TV';
        testPromoterShare.CurrencyIsoCode = 'USD';
        System.debug(Schema.SObjectType.PromoterShare__c.getRecordTypeInfosByDeveloperName().get('InHouseShare').getRecordTypeId());
        testPromoterShare.RecordTypeId = Schema.SObjectType.PromoterShare__c.getRecordTypeInfosByDeveloperName().get('InHouseShare').getRecordTypeId();
        Insert testPromoterShare;
        
        Map<String,String> recordMap = new Map<String,String>();  
        recordMap.put('Id',testPromoterShare.Id);
        recordMap.put('fieldsEdit','true');
        recordMap.put('Store__c',String.valueOf(testShop.id));
        recordMap.put('Customer__c',String.valueOf(customerTest.id));
        recordMap.put('Market__c',String.valueOf(testMarket.id));
        recordMap.put('CurrencyIsoCode','USD');
        recordMap.put('ProductLine__c','TV');
        recordMap.put('RecordTypeId',String.valueOf(testPromoterShare.RecordTypeId));
        
        Map<String,String> recordMap2 = new Map<String,String>();  
        recordMap2.put('Store__c',String.valueOf(testShop.id));
        recordMap2.put('Customer__c',String.valueOf(customerTest.id));
        recordMap2.put('Market__c',String.valueOf(testMarket.id));
        recordMap2.put('CurrencyIsoCode','USD');
        recordMap2.put('ProductLine__c','TV');
        recordMap2.put('RecordTypeId',String.valueOf(testPromoterShare.RecordTypeId));
        
		List<Map<String,String>> recordList = new List<Map<String,String>>();
        recordList.add(recordMap);
        String recordDataJson = Json.serialize(recordList);
        
        List<Map<String,String>> recordList2 = new List<Map<String,String>>();
        recordList2.add(recordMap2);
        String recordDataJson2 = Json.serialize(recordList2);
        
        List<String> deleteList = new List<String>();
		deleteList.add(testPromoterShare.Id);  
        
        Map<String,Object> fileMap = new Map<String,Object>();
        fileMap.put('1',testPromoterShare);
        String fileMapJson = Json.serialize(fileMap);
        
        String recordTypeName = 'In House Share';
        
        Test.startTest();
        PromoterShareController.getInitData(testMarket.Id,recordTypeName);
        PromoterShareController.saveRecord(recordDataJson,deleteList,fileMapJson,testMarket.id,testPromoterShare.RecordTypeId);
        PromoterShareController.saveRecord(recordDataJson2,deleteList,fileMapJson,testMarket.id,testPromoterShare.RecordTypeId);
        Test.stopTest();
    }
}