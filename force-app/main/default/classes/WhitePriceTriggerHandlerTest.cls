@isTest
public class WhitePriceTriggerHandlerTest {

    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    
    @isTest
    static void testWhitePriceTriggerHandler(){
        
        Test.startTest();
        
        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.sales_region__c = 'Hisense Chile';
        product.RecordTypeId = productRecordTypeId;
        insert product;
        
        WhitePrice__c item = new WhitePrice__c();
        item.Product__c = product.Id;
        insert item;
        
        Product__c product2 = new Product__c();
        product2.Name = '65A60G';
        product2.sales_region__c = 'Hisense Chile';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;
        
        item.Product__c = product2.Id;
        item.WhitePrice__c = 288;
        update item;
        
        Test.stopTest();
        
    }
}