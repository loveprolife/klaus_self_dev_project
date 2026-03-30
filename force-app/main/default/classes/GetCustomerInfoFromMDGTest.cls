@isTest
public class GetCustomerInfoFromMDGTest {

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
    static void testGetCustomerInformationFromMDG_Success() {

        // 设置 mock
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"001234567890123456","SYNSTATUS":"S","DATA":[{"DATA":{"PARTNER":"123456","ZZRENO":"123456",,"NAME_EN":"Test Customer"}}]}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        // 执行 callout
        GetCustomerInfoFromMDG.CustomerInfo customerInfo = GetCustomerInfoFromMDG.getCustomerInformationFromMDG('CN', 'Trader', '123456');
        Test.stopTest();

        // 验证结果
        // System.assertEquals('123456', customerInfo.PARTNER);
    }

    @isTest
    static void testGetCustomerInformationFromMDG_Failure() {
        // Mock the HTTP response for a failed API call
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"SYNSTATUS":"F","SYNRESULT":"Error message"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        Test.startTest();
        // 执行 callout
        // Call the method and assert the expected outcome
        GetCustomerInfoFromMDG.CustomerInfo customerInfo = GetCustomerInfoFromMDG.getCustomerInformationFromMDG('CN', 'Trader', '123456');
        Test.stopTest();
        
        // 验证结果
        System.assertEquals(null, customerInfo.AUFSD);
    }

    @isTest
    static void testGetCustomerInformationByDateTimeFromMDG_Success() {
        // Mock the HTTP response for a successful API call
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"001234567890123456","SYNSTATUS":"S","DATA":[{"DATA":{"PARTNER":"123456","NAME_EN":"Test Customer"}}]}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        // 执行 callout
        // Call the method and assert the expected outcome
        List<GetCustomerInfoFromMDG.DATA> dataList = GetCustomerInfoFromMDG.getCustomerInformationByDateTimeFromMDG('202409081234');
        Test.stopTest();
        
        // 验证结果
        System.assertEquals(1, dataList.size());
        System.assertEquals('123456', dataList[0].DATA.PARTNER);
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