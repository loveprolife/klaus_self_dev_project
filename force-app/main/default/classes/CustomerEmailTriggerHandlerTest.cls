@isTest
private class CustomerEmailTriggerHandlerTest {
    
    static testmethod void test() {

        Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.Hisense_Entity__c = '8110';
        acc1.Trader_Type__c = 'H002';
        insert(acc1);

        Test.startTest();
        Customer_Email__c ce = new Customer_Email__c();
        ce.Email__c = '123@qq.com';
        ce.Customer__c = acc1.Id;
        insert ce;

        Customer_Email__c ce1 = new Customer_Email__c();
        ce1.Email__c = '123456@qq.com';
        ce1.Customer__c = acc1.Id;
        insert ce1;

        ce1.No__c  = 1;
        update ce1;

        ce1.No__c = 2;
        update ce1;

        delete ce1;

        Test.stopTest();
    }

    static testmethod void test1() {

        Account acc1 = new Account();
    	acc1.Name = 'Test Account002Test Account002Test Account002Test Account002Test Account00';
        acc1.SAP_Customer_Code__c = '1772378988';
        acc1.External_Key__c = '1772378988';
        acc1.Hisense_Entity__c = '8110';
        acc1.Trader_Type__c = 'H002';
        insert(acc1);

        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc1.Id;
        insert ca;

        Test.startTest();
        Customer_Email__c ce = new Customer_Email__c();
        ce.Email__c = '123@qq.com';
        ce.Customer_Address__c = ca.Id;
        insert ce;

        Customer_Email__c ce1 = new Customer_Email__c();
        ce1.Email__c = '123456@qq.com';
        ce1.Customer_Address__c = ca.Id;
        insert ce1;

        ce1.No__c  = 1;
        update ce1;

        ce1.No__c = 2;
        update ce1;

        delete ce1;

        Test.stopTest();

        
    }
 
}