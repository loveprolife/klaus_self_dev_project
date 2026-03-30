@isTest
public class Php_StoreSoInventorySchedulableTest {

    @isTest
    static void testMethodSchedulable(){

        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.sales_region__c = 'Hisense Philippines';
        insert store;

        Inventory_Sales_Report__c invent = new Inventory_Sales_Report__c();

        invent.Product_Line__c = 'ACF';
        invent.Product_Model__c = 'S100';
        insert invent;

        Test.startTest();
        System.schedule('Php_StoreSoInventorySchedulable', '0 0 * * * ?', new Php_StoreSoInventorySchedulable());
        Test.stopTest();
    }
}