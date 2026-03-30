@isTest
private class GetMakroChannelSchedulableTest {
    static testMethod void testMethod1() {
        GetMakroChannelSchedulable cis = new GetMakroChannelSchedulable('111');
        SchedulableContext sc;
        cis.execute(sc);
    }
}