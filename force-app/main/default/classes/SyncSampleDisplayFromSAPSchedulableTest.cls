@isTest
private class SyncSampleDisplayFromSAPSchedulableTest {
    static testMethod void testMethod1() {

        TestDataUtility.createCustomSettings();
        
        SyncSampleDisplayFromSAPSchedulable cis = new SyncSampleDisplayFromSAPSchedulable('111');
        SchedulableContext sc;
        cis.execute(sc);

    }

}