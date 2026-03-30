@isTest
public class ReturnsAndCreditControllerTest {
	@isTest
    static void testReturnsAndCreditController(){
        Account customerTest = new Account();
        customerTest.Name = '测试ReturnsAndCreditController客户0629';
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试ReturnsAndCreditController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Promoter_Daily_Report__c testReport = new Promoter_Daily_Report__c();
        testReport.Customer__c =  customerTest.id;
        testReport.Shop__c = testShop.id;
        //testReport.Name = '测试PromoterShare用';
        Insert testReport;
        
        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
       	Insert productTest;
        
        ReturnsAndCredit__c testReturnsAndCredit = new ReturnsAndCredit__c();
        testReturnsAndCredit.Product__c = productTest.id;
        testReturnsAndCredit.Customer__c = customerTest.Id;
        testReturnsAndCredit.Store__c = testShop.id;
        testReturnsAndCredit.PromoterDailyReport__c = testReport.id;
        testReturnsAndCredit.Quantity__c = 100;
        Insert testReturnsAndCredit;
        
        Map<String,String> recordMap = new Map<String,String>();  
        recordMap.put('Id',testReturnsAndCredit.Id);
        recordMap.put('fieldsEdit','true');
        recordMap.put('Store__c',String.valueOf(testShop.id));
        recordMap.put('Customer__c',String.valueOf(customerTest.id));
        recordMap.put('PromoterDailyReport__c',String.valueOf(testReport.id));
        recordMap.put('Product__c',String.valueOf(productTest.id));
        recordMap.put('Quantity__c',String.valueOf(10));
        
        Map<String,String> recordMap2 = new Map<String,String>();  
        recordMap2.put('Store__c',String.valueOf(testShop.id));
        recordMap2.put('Customer__c',String.valueOf(customerTest.id));
        recordMap2.put('PromoterDailyReport__c',String.valueOf(testReport.id));
        recordMap2.put('Product__c',String.valueOf(productTest.id));
        recordMap2.put('Quantity__c',String.valueOf(10));
        
        List<Map<String,String>> recordList = new List<Map<String,String>>();
        recordList.add(recordMap);
        String recordDataJson = Json.serialize(recordList);
        
        List<Map<String,String>> recordList2 = new List<Map<String,String>>();
        recordList2.add(recordMap2);
        String recordDataJson2 = Json.serialize(recordList2);
        
        List<String> deleteList = new List<String>();
		deleteList.add(testReturnsAndCredit.Id);  
        
        Map<String,Object> fileMap = new Map<String,Object>();
        fileMap.put('1',testReturnsAndCredit);
        String fileMapJson = Json.serialize(fileMap);
        
        Test.startTest();
        ReturnsAndCreditController.getInitData(testReport.Id);
        ReturnsAndCreditController.saveRecord(recordDataJson,deleteList,fileMapJson,testReport.id);
        ReturnsAndCreditController.saveRecord(recordDataJson2,deleteList,fileMapJson,testReport.id);
        //testReturnsAndCredit.Quantity__c = 200;
        //update testReturnsAndCredit;
        Test.stopTest();
    }
}