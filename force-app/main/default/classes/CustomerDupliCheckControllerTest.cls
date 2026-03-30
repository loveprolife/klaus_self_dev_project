@isTest
public class CustomerDupliCheckControllerTest {
    
    @testSetup
    static void setup() {
        // 首先创建测试数据
        MDG_Interface__c mdgInterface = new MDG_Interface__c(
            Name = 'CustomerQuery', 
            Url__c = 'https://test.url',
            AppId__c = 'testAppId',
            ClientId__c = 'testClientId',
            If_Id__c = 'testIfId',
            SecretKey__c = 'testSecretKey'
        );
        insert mdgInterface;
        
    }

    @isTest
    static void methodTest0(){
        
        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        Test.startTest();
        CustomerDupliCheckController.getRecordTypeDeveloperName(customerRTId);
        CustomerDupliCheckController.getCountryList();
        CustomerDupliCheckController.getIdTypeList();
        CustomerDupliCheckController.stringToDate('12345');
        CustomerDupliCheckController.stringToDate('20240101');
        Test.stopTest();
    }

    @isTest
    static void methodTest1(){
        
        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        String profileName = 'Canada Sales Manager';
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(
            alias = 'test', 
            email='DailySalesUploadControllerTest@noemail.com',
            emailencodingkey='UTF-8', 
            lastname='canadaSalesTest', 
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = profileId,
            country='Canada',
            IsActive =true,
            timezonesidkey='America/Los_Angeles', 
            username='DailySalesUploadControllerTest@noemail.com',
            Sales_Region__c='Hisense Canada');
        INSERT user1;
        
        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.RecordTypeId = customerRTId;
        acc.Sales_Region__c = 'Hisense Canada';
        acc.Guarantor_Country_Code__c = 'CA';
        acc.Company_Registration_Number__c = '1001001';
        Insert acc;
        
        Test.startTest();
        System.runAs(user1) {
            CustomerDupliCheckController.findAccount('CA', '1001001', customerRTId);
            CustomerDupliCheckController.getParentCustomerInfo(acc.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void methodTest2(){
        
        String customerRTId = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('customer').getRecordTypeId();

        // Mock the HTTP response for a successful API call
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"001234567890123456","SYNSTATUS":"S","DATA":[{"DATA":{"PARTNER":"1001001","NAME_EN":"Test Customer"}}]}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        // 执行 callout
        // Call the method and assert the expected outcome
        CustomerDupliCheckController.findAccount('CA', '1001001', customerRTId);
        Test.stopTest();
    }

    // MockHttpResponseGenerator
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