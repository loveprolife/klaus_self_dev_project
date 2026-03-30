@isTest
private class GetAvailableInventorySchedulableTest {
    static testMethod void testMethod1() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'SAP',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
        GetAvailableInventorySchedulable cis = new GetAvailableInventorySchedulable('111');
        SchedulableContext sc;
        cis.execute(sc);
    }
}