@isTest
public class MarketInsightControllerTest {
	@IsTest
    static void testMarketInsightController(){
        Test.startTest();
        
        NewTestDataUtility.makePromoterDailyReportData();
        NewTestDataUtility.makeBrandData();
        Account customer = NewTestDataUtility.customer;
        Shop__c store = NewTestDataUtility.store;
        Account brand = NewTestDataUtility.brand;
        Market__c market = NewTestDataUtility.market;
        String recordId = market.Id;
        MarketInsightController.getInitData(recordId);
        
		MarketInsight__c item = new MarketInsight__c();
        item.Market__c = market.Id;
        item.Store__c = store.Id;
        item.Brand__c = brand.Id;
        item.Quantity__c = 2;
        insert item;
        Map<String, Object> recordDataMap = new Map<String, Object>();
        recordDataMap.put('Store__c', store.Id);
        recordDataMap.put('Brand__c', brand.Id);
        recordDataMap.put('Quantity__c', 2);
        String recordDataJson = Json.serialize(new List<Map<String, Object>>{recordDataMap});
        MarketInsightController.getInitData(recordId);
        MarketInsightController.saveRecord(recordDataJson, new List<String>(), '', recordId);
        
        Shop__c store2 = new Shop__c();
        store2.Name = 'Hi Fi Corporation NEWCASTLE2';
        store2.Account__c = customer.Id;
        insert store2;
        recordDataMap.put('Id', item.Id);
        recordDataMap.put('Store__c', store2.Id);
        recordDataMap.put('fieldsEdit', 'true');
        recordDataJson = Json.serialize(new List<Map<String, Object>>{recordDataMap});
        MarketInsightController.saveRecord(recordDataJson, new List<String>(), '', recordId);
        
        recordDataJson = Json.serialize(new List<Map<String, Object>>());
        System.debug('item.Id：' + item.Id);
        MarketInsightController.saveRecord(recordDataJson, new List<String>{item.Id}, '', recordId);  
        
        Test.stopTest();
    }
}