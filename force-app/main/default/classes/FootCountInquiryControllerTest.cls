@isTest
public class FootCountInquiryControllerTest {
	@isTest
    static void testFootCountInquiryController(){
        Account customerTest = new Account();
        customerTest.Name = '测试FootCountInquiryController客户0628';
        Insert customerTest;
        
        Account customerTest2 = new Account();
        customerTest2.Name = '客户';
        Insert customerTest2;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试FootCountInquiryController门店0628(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Research__c testResearch = new Research__c();
        // testResearch.Customer__c =  customerTest.id;
        testResearch.Shop__c = testShop.id;
        //testResearch.Name = '测试FootCountInquiryController用';
        Insert testResearch;
        
        FootCountInquiry__c testFootCountInquiry = new FootCountInquiry__c();
        testFootCountInquiry.Store__c = testShop.id;
        testFootCountInquiry.Research__c = testResearch.id;
        testFootCountInquiry.Customer__c = customerTest.id;
        testFootCountInquiry.CurrencyIsoCode = 'USD';
        insert testFootCountInquiry;
        
        Map<String,String> recordMap = new Map<String,String>();  
        recordMap.put('Store__c',String.valueOf(testShop.id));
        recordMap.put('Research__c',String.valueOf(testResearch.id));
        recordMap.put('Customer__c',String.valueOf(customerTest.id));
        recordMap.put('CurrencyIsoCode','USD');
        recordMap.put('fieldsEdit','true');
        
        List<Map<String,String>> recordList = new List<Map<String,String>>();
        recordList.add(recordMap);
        String recordDataJson = Json.serialize(recordList);
        
        Test.startTest();
        FootCountInquiryController.getInitData('');
        FootCountInquiryController.getInitData(testResearch.Id);
        FootCountInquiryController.saveRecord(recordDataJson,testResearch.id);
        testFootCountInquiry.Customer__c = customerTest2.id;
        update testFootCountInquiry;
        Test.stopTest();
    }
}