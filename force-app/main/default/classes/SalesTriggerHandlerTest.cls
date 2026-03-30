@isTest
private class SalesTriggerHandlerTest {
    static testMethod void testMethod1() {
    	Test.startTest();
    	Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);

        User u = new User();
        Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        u.username = 'HisenseSSORegHandlerTest@salesforce.com';
        u.email = 'HisenseSSORegHandlerTest@salesforce.com';
        u.lastName = 'HisenseSSORegHandlerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.HisenseSSOName__c = 'testId';
        insert u;

        User u2 = new User();        
        u2.username = 'loimnhk@salesforce.com';
        u2.email = 'loimnhk@salesforce.com';
        u2.lastName = 'Hmnhk';

        u2.alias ='casdf';
        u2.languagelocalekey = 'en_US';
        u2.localesidkey = 'en_US';
        u2.emailEncodingKey = 'UTF-8';
        u2.timeZoneSidKey = 'America/Los_Angeles';
        u2.profileId = p.Id;
        u2.HisenseSSOName__c = 'testIdfds';
        insert u2;

        Sales__c s = new Sales__c();
        s.Customer__c = acc1.id;
        s.Sales__c = u.id;

        Database.insert(s);
        s.Sales__c = u2.Id;
        Database.update(s);
        
        Database.delete(s);
        Test.stopTest();
    }
}