@isTest
private class SendCustomerInfoToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Account a = new Account();
        a.SAP_Customer_Code__c = 'aaaa';
        a.Name = 'test001';
        insert a;
        SendCustomerInfoToBigData.adoPost() ; 
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Test.startTest();
        Account a = new Account();
        a.SAP_Customer_Code__c = '0000';
        a.Name = 'test001';
        insert a;
        SendCustomerInfoToBigData.adoPost() ; 
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        Test.startTest();
        Customer_Management__c c = new Customer_Management__c();
        c.Name = 'Test';
        insert c;
        List<Customer_Management__c> cm = [select Id from Customer_Management__c];
        
        Account a = new Account();
        a.SAP_Customer_Code__c = '0000';
        a.Name = 'test001';
        a.Customer_Management_Name__c = cm[0].Id;
        insert a;
        SendCustomerInfoToBigData.adoPost() ; 
        Test.stopTest();
    }
}