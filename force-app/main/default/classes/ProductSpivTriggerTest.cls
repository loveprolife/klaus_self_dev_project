@isTest
public with sharing class ProductSpivTriggerTest {
	@isTest
    static void testMethod1(){
        Account customerTest = new Account();
        customerTest.Name = '测试客户0726';
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试spiv门店';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
       	productTest.Name = 'NTC-22E-TV';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        
        ProductSpiv__c testSpiv1 = new ProductSpiv__c();
        testSpiv1.SPIV__c = 8;
        testSpiv1.Product__c = productTest.id;
        testSpiv1.StartTime__c = Datetime.newInstance(2023,7,1,12,0,0);
        testSpiv1.EndTime__c = Datetime.newInstance(2023,8,1,12,0,0);
        testSpiv1.Sales_Region__c = 'Hisense South Africa';
        //testSpiv1.Country__c = 'South Africa';
        testSpiv1.IsActive__c = true;
        insert testSpiv1;
        
        ProductSpiv__c testSpiv2 = new ProductSpiv__c();
        testSpiv2.SPIV__c = 4;
        testSpiv2.Product__c = productTest.id;
        testSpiv2.StartTime__c = Datetime.newInstance(2023,7,15,12,0,0);
        testSpiv2.EndTime__c = Datetime.newInstance(2023,8,15,12,0,0);
        testSpiv2.Sales_Region__c = 'Hisense South Africa';
        //testSpiv2.Country__c = 'South Africa';
        testSpiv2.IsActive__c = true;
        //insert testSpiv1;
        
        ProductSpiv__c testSpiv3 = new ProductSpiv__c();
        testSpiv3.SPIV__c = 5;
        testSpiv3.Product__c = productTest.id;
        testSpiv3.StartTime__c = Datetime.newInstance(2023,8,2,12,0,0);
        testSpiv3.EndTime__c = Datetime.newInstance(2023,9,1,12,0,0);
        testSpiv3.Sales_Region__c = 'Hisense South Africa';
        //testSpiv3.Country__c = 'South Africa';
        testSpiv3.IsActive__c = true;
        //insert testSpiv3;
        
        List<ProductSpiv__c> spivList = new List<ProductSpiv__c>();
		spivList.add(testSpiv2);
        spivList.add(testSpiv3);
        
        Test.startTest();
        try{
           insert spivList; 
        }catch(Exception e){
            System.debug(e);
        }
        insert testSpiv3;
        testSpiv3.StartTime__c = Datetime.newInstance(2023,7,15,12,0,0);
        try{
           update testSpiv3; 
        }catch(Exception e){
            System.debug(e);
        }
        Test.stopTest();
        
    }
}