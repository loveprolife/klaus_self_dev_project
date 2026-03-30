@isTest
public class ConsumerTraitResearchControllerTest {
	@isTest
    static void testConsumerTraitResearchController(){
        Account customerTest = new Account();
        customerTest.Name = '测试ConsumerTraitResearch客户0628';
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试ConsumerTraitResearch门店0628(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Research__c testResearch = new Research__c();
        // testResearch.Customer__c =  customerTest.id;
        testResearch.Shop__c = testShop.id;
        //testResearch.Name = '测试PromoterShare用';
        Insert testResearch;
        
        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-jp';
       	Insert productTest;
        
        ConsumerTraitResearch__c testConsumerTraitResearch = new ConsumerTraitResearch__c();
        testConsumerTraitResearch.Store__c = testShop.id;
        testConsumerTraitResearch.Name = '测试Consumer';
        testConsumerTraitResearch.Product__c = productTest.id;
        testConsumerTraitResearch.Research__c = testResearch.id;
        testConsumerTraitResearch.Quantity__c = 10;
        Insert testConsumerTraitResearch;
        
        Map<String,String> recordMap = new Map<String,String>();
        recordMap.put('Id',testConsumerTraitResearch.Id);
        recordMap.put('fieldsEdit','true');
        recordMap.put('Store__c',String.valueOf(testShop.id));
        recordMap.put('Name','测试Consumer');
        recordMap.put('Research__c',String.valueOf(testResearch.id));
        recordMap.put('CurrencyIsoCode','USD');
        recordMap.put('Product__c',String.valueOf(productTest.id));
        recordMap.put('Quantity__c',String.valueOf(10));
        
        Map<String,String> recordMap2 = new Map<String,String>();
        recordMap2.put('Store__c',String.valueOf(testShop.id));
        recordMap2.put('Name','测试Consumer');
        recordMap2.put('Research__c',String.valueOf(testResearch.id));
        recordMap2.put('CurrencyIsoCode','USD');
        recordMap2.put('Product__c',String.valueOf(productTest.id));
        recordMap2.put('Quantity__c',String.valueOf(10));
        
        List<Map<String,String>> recordList = new List<Map<String,String>>();
        recordList.add(recordMap);
        String recordDataJson = Json.serialize(recordList);
        
        List<Map<String,String>> recordList2 = new List<Map<String,String>>();
        recordList2.add(recordMap2);
        String recordDataJson2 = Json.serialize(recordList2);
        
        List<String> deleteList = new List<String>();
		deleteList.add(testConsumerTraitResearch.Id);  
        
        Test.startTest();
        ConsumerTraitResearchController.getInitData(testResearch.Id);
        ConsumerTraitResearchController.saveRecord(recordDataJson,deleteList,testResearch.id);
        ConsumerTraitResearchController.saveRecord(recordDataJson2,deleteList,testResearch.id);
        Test.stopTest();
        
    }
}