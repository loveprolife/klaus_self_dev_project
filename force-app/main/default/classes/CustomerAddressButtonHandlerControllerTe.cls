@isTest
public with sharing class CustomerAddressButtonHandlerControllerTe {
    @testSetup
    static void setup() {
        // 首先创建测试数据
        MDG_Interface__c mdgInterface = new MDG_Interface__c(
            Name = 'CustomerMaintain', 
            Url__c = 'https://test.url',
            AppId__c = 'testAppId',
            ClientId__c = 'testClientId',
            If_Id__c = 'testIfId',
            SecretKey__c = 'testSecretKey'
        );
        insert mdgInterface;
        
    }

    static testMethod void testMethod1() {

        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.RecordTypeId = customerRTId;
        acc.Sales_Region__c = 'Hisense Canada';
        acc.Guarantor_Country_Code__c = 'CA';
        acc.Company_Registration_Number__c = '1001001';
        acc.MDG_Customer_Code__c = '123456';
        acc.SAP_Customer_Code__c = '123456';
        insert acc;
        
        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc.Id;
        insert ca;

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"001234567890123456","SYNSTATUS":"S","DATA":[{"DATA":{"PARTNER":"123456","NAME_EN":"Test Customer"}}]}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        CustomerAddressButtonHandlerController.syncCustomerToSAP(ca.Id);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        
        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.RecordTypeId = customerRTId;
        acc.Sales_Region__c = 'Hisense Canada';
        acc.Guarantor_Country_Code__c = 'CA';
        acc.Company_Registration_Number__c = '1001001';
        acc.MDG_Customer_Code__c = '123456';
        acc.SAP_Customer_Code__c = '123456';
        insert acc;
        
        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc.Id;
        insert ca;
        
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"SYNSTATUS":"F","SYNRESULT":"Error message"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        CustomerAddressButtonHandlerController.syncCustomerToSAP(ca.Id);
        Test.stopTest();
    }

    static testMethod void testMethod3() {

        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.RecordTypeId = customerRTId;
        acc.Sales_Region__c = 'Hisense Canada';
        acc.Guarantor_Country_Code__c = 'CA';
        acc.Company_Registration_Number__c = '1001001';
        insert acc;
        
        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc.Id;
        insert ca;

        Test.startTest();
        CustomerAddressButtonHandlerController.syncCustomerToSAP(ca.Id);
        Test.stopTest();
    }

    static testMethod void testMethod4() {

        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.RecordTypeId = customerRTId;
        acc.Sales_Region__c = 'Hisense Canada';
        acc.Guarantor_Country_Code__c = 'CA';
        acc.Company_Registration_Number__c = '1001001';
        insert acc;
        
        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc.Id;
        ca.Approval_Status__c = 'Approved';
        insert ca;

        Test.startTest();
        CustomerAddressButtonHandlerController.syncCustomerToSAP(ca.Id);
        Test.stopTest();
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}