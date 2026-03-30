@isTest
private class SyncCustomerInfoCheckToSAPTest {
    
    @isTest
    static void testPostCustomerInfomationToMDG_NewCustomer() {

        // 创建必要的自定义设置记录
        MDG_Interface__c mdgInterface = new MDG_Interface__c(
            Name = 'SyncCustomerInfoCheckToSAP',
            Url__c = 'https://test.url',
            AppId__c = 'testAppId',
            SecretKey__c = 'testSecretKey',
            Server__c = '123'
        );
        insert mdgInterface;
        SyncCustomerInfoToMDGPro.InterfaceBody IV_INPUT = new SyncCustomerInfoToMDGPro.InterfaceBody();
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoCheckToSAP.syncCustomerInfoCheckToSAP(IV_INPUT,'');
        Test.stopTest();
        
    }

    // Mock HTTP Response Generator
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