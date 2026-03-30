@isTest
private class Batch_SapProductCreateTest {
    static testMethod void testMethod1() {
        Sap_Product__c sp = new Sap_Product__c(
            ZCUSMODEL__c = 'Test Product',
            Is_New__c = true,
            External_key__c = 'Test Product'
        );
        insert sp;

        Batch_SapProductCreate ss  =new Batch_SapProductCreate();
		Database.executeBatch(ss);
    }
}