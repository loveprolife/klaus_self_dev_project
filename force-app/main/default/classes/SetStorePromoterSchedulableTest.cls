@isTest
private class SetStorePromoterSchedulableTest {
    static testMethod void testMethod1() {

        TestDataUtility.createCustomSettings();
        
        SetStorePromoterSchedulable cis = new SetStorePromoterSchedulable('111');
        SchedulableContext sc;
        cis.execute(sc);

    }

}