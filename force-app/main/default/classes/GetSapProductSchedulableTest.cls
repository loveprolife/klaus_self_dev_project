@isTest
private class GetSapProductSchedulableTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        GetSapProductSchedulable cis = new GetSapProductSchedulable();
        SchedulableContext sc;
        cis.execute(sc);
    }
    
    static testMethod void testMethod3() {
        TestDataUtility.createCustomSettings();
        GetSapProductSchedulable cis = new GetSapProductSchedulable('test','20230423','20230424',0,true,true);
        SchedulableContext sc;
        cis.execute(sc);
    }
}