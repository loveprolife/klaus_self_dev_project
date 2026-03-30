@isTest
private class StoreProductLineTriggerHandlerTest {
    static testMethod void testMethod1() {
        
        Shop__c ss = new Shop__c();
        ss.Name = 'test';
        insert ss;
        Store_Product_Line__c s = new Store_Product_Line__c();
        s.Product_Line__c = 'TV';
        s.Store__c = ss.id;
        insert s;

        s.Product_Line__c = 'AC';
        update s;

    }

   
}