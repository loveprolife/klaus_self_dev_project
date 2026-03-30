@isTest
private class SyncCustomerInfoToMDGTest {
    
    @testSetup
    static void setup() {

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'US';
        insert tcm1;

        // 创建必要的自定义设置记录
        MDG_Interface__c mdgInterface = new MDG_Interface__c(
            Name = 'CustomerMaintain',
            Url__c = 'https://test.url',
            AppId__c = 'testAppId',
            ClientId__c = '300',
            If_Id__c = 'Customer_maintain',
            SecretKey__c = 'testSecretKey',
            Server__c = '123',
            PCOMPANY__c = 'testCompany'
        );
        insert mdgInterface;

        //RecordType
        RecordType subAccountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Sub_Account' LIMIT 1];
        //RecordType
        RecordType addressRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer_Address' LIMIT 1];
        
        // 创建测试账户1
        Account testAccount = new Account(
            Name = 'Test Account',
            Customer_Name_Local_Language__c = 'Test Account',
            Customer_Short_Name__c = 'TA',
            Phone = '1234567890',
            Trader_Type__c = 'H001',
            CustomerDetailType__c = '10',
            Guarantor_Country_Code__c = 'CN',
            Hisense_Entity__c = '8110',
            Hisense_Entity_Sales__c = '8110',
            E_commerce_Customer_Label__c = '10',
            Approval_Status__c = 'Approved',
            RecordTypeId = subAccountRecordType.Id
        );
        insert testAccount;
        
        // 创建测试账户2
        Account testAccount2 = new Account(
            Name = 'Test Account2',
            Customer_Name_Local_Language__c = 'Test Account2',
            Customer_Short_Name__c = 'TA2',
            Phone = '1234567890',
            Trader_Type__c = 'H002',
            CustomerDetailType__c = '10',
            E_commerce_Customer_Label__c = '10',
            Approval_Status__c = 'Approved',
            Guarantor_Country_Code__c = 'CN'
        );
        insert testAccount2;

        // 创建测试账户3
        Account testAccount3 = new Account(
            Name = 'Test Account3',
            Customer_Name_Local_Language__c = 'Test Account3',
            Customer_Short_Name__c = 'TA3',
            Phone = '1234567890',
            Trader_Type__c = 'H002',
            CustomerDetailType__c = '10',
            E_commerce_Customer_Label__c = '10',
            Guarantor_Country_Code__c = 'CN',
            Approval_Status__c = 'Approved',
            RecordTypeId = addressRecordType.Id
        );
        insert testAccount3;

        // 创建测试付款条件
        Payment_Term__c paymentTerm = new Payment_Term__c(
            Name = 'PT001'
        );
        insert paymentTerm;

        // 创建测试国家州省记录
        Country_State__c countryState = new Country_State__c(
            Name__c = 'Test State',
            Belong_To__c = 'CN'
        );
        insert countryState;

        // 创建测试选择列表
        PickList__c pickList = new PickList__c(
            Name = 'Test Picklist',
            Value__c = 'Test Value'
        );
        insert pickList;
        
        // 创建税分类组织mapping记录
        TaxCountryMapping__c taxMapping = new TaxCountryMapping__c(
            Name= '8010',
            HisenseEntity__c = '8010',                    // HisenseEntity
            Country__c = 'CN'   // 国家代码
        );
        insert taxMapping;
    }

    @isTest
    static void testPostCustomerInfomationToMDG_NewCustomer() {
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        //RecordType
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'customer' LIMIT 1];
        
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(testAccount.Id);
        testAccount.RecordTypeId = customerRecordType.Id;
        update testAccount;
        String result2 = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_ExistingCustomer() {
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        testAccount.MDG_Customer_Code__c = '12345';
        update testAccount;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_CustomerExtend() {
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        //RecordType
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'customer' LIMIT 1];
        
        testAccount.RecordTypeId = customerRecordType.Id;
        update testAccount;
        
        // 创建客户扩展记录
        Customer_Extend__c customerExtend = new Customer_Extend__c(
            Customer__c = testAccount.Id,
            E_commerce_Customer_Label__c = '10',
            Show_Company__c = True,
            Show_Sales__c = True,
            Hisense_Entity__c = '8010',
            Hisense_Entity_Sales__c = '8010',
            Payment_Term__c = [SELECT Id FROM Payment_Term__c LIMIT 1].Id
        );
        insert customerExtend;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(customerExtend.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_CustomerExtend_SubAccount() {
        
        //RecordType
        RecordType subAccountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Sub Account' LIMIT 1];
        
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // 创建客户扩展记录
        Customer_Extend__c customerExtend = new Customer_Extend__c(
            Customer__c = testAccount.Id,
            E_commerce_Customer_Label__c = '10',
            Show_Company__c = True,
            Show_Sales__c = True,
            Extend_or_Not__c = True,
            Hisense_Entity__c = '8010',
            Hisense_Entity_Sales__c = '8010',
            Payment_Term__c = [SELECT Id FROM Payment_Term__c LIMIT 1].Id
        );
        insert customerExtend;
        
        // 创建测试账户1
        Account testAccount3 = new Account(
            Name = 'Test Account3',
            Customer_Name_Local_Language__c = 'Test Account3',
            Customer_Short_Name__c = 'TA',
            Phone = '1234567890',
            Trader_Type__c = 'H001',
            CustomerDetailType__c = '10',
            Guarantor_Country_Code__c = 'CN',
            Hisense_Entity__c = '8110',
            E_commerce_Customer_Label__c = '10',
            ParentCustomerOfSubAcc__c = testAccount.Id,
            Customer_Extend_Sub_Account__c = customerExtend.Id,
            Customer_Extend_Sales__c = customerExtend.Id,
            RecordTypeId = subAccountRecordType.Id
        );
        insert testAccount3;

        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(testAccount3.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testPostCustomerInfomationToMDG_CustomerAddress() {
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // 创建客户扩展记录
        Customer_Extend__c customerExtend = new Customer_Extend__c(
            Customer__c = testAccount.Id,
            E_commerce_Customer_Label__c = '10',
            Show_Company__c = True,
            Show_Sales__c = True,
            Hisense_Entity__c = '8010',
            Hisense_Entity_Sales__c = '8010',
            Payment_Term__c = [SELECT Id FROM Payment_Term__c LIMIT 1].Id
        );
        insert customerExtend;
        // 创建客户扩展记录
        Customer_Address__c cad = new Customer_Address__c(
            Customer__c = testAccount.Id,
            Customer_Extend__c = customerExtend.Id,
            Customer_Extend_Sales__c = customerExtend.Id
        );
        insert cad;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(cad.Id);
        Test.stopTest();
        
        //System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_CustomerAddress_SubAccount() {
        //RecordType
        RecordType subAccountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Sub Account' LIMIT 1];
        
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // 创建客户扩展记录
        Customer_Extend__c customerExtendOriginal = new Customer_Extend__c(
            Customer__c = testAccount.Id,
            E_commerce_Customer_Label__c = '10',
            Show_Company__c = True,
            Show_Sales__c = True,
            Extend_or_Not__c = True,
            Hisense_Entity__c = '8010',
            Hisense_Entity_Sales__c = '8010',
            Payment_Term__c = [SELECT Id FROM Payment_Term__c LIMIT 1].Id
        );
        insert customerExtendOriginal;
        
        // 创建测试账户1
        Account testAccount3 = new Account(
            Name = 'Test Account3',
            Customer_Name_Local_Language__c = 'Test Account3',
            Customer_Short_Name__c = 'TA',
            Phone = '1234567890',
            Trader_Type__c = 'H001',
            CustomerDetailType__c = '10',
            Guarantor_Country_Code__c = 'CN',
            Hisense_Entity__c = '8110',
            E_commerce_Customer_Label__c = '10',
            ParentCustomerOfSubAcc__c = testAccount.Id,
            Customer_Extend_Sub_Account__c = customerExtendOriginal.Id,
            Customer_Extend_Sales__c = customerExtendOriginal.Id,
            RecordTypeId = subAccountRecordType.Id
        );
        insert testAccount3;

        // 创建客户扩展记录
        Customer_Address__c cad = new Customer_Address__c(
            Customer__c = testAccount3.Id
        );
        insert cad;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(cad.Id);
        String result1 = SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG(testAccount.Id);
        result1 = SyncCustomerInfoToMDGPro1.postCustomerInfomationToMDG(testAccount.Id);
        Test.stopTest();
        
        //System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_CustomerAddress_Account() {
        
        // 创建测试账户1
        Account testAccount3 = new Account(
            Name = 'Test Account3',
            Customer_Name_Local_Language__c = '测试账户',
            Customer_Short_Name__c = 'TA',
            Phone = '1234567890',
            Trader_Type__c = 'H006',
            CustomerDetailType__c = '18',
            Guarantor_Country_Code__c = 'CN',
            Hisense_Entity__c = '8110',
            Hisense_Entity_Sales__c = '8110',
            E_commerce_Customer_Label__c = '10'
        );
        insert testAccount3;

        // 创建客户扩展记录
        Customer_Address__c cad = new Customer_Address__c(
            Customer__c = testAccount3.Id
        );
        insert cad;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(cad.Id);
        Test.stopTest();
        
        //System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_CustomerBanks() {
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // 创建客户银行记录
        Customer_Banks__c customerBank = new Customer_Banks__c(
            Customer__c = testAccount.Id,
            Bank_Account__c = '123456789',
            Approval_Status__c = 'Approved',
            Bank_Code__c = '123456789', 
            Bank_Country__c='CN', 
            Bank_Name__c='Test', 
            Bank_name_local_language__c='Chinese'
        );
        insert customerBank;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345"}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result = SyncCustomerInfoToMDG.postCustomerInfomationToMDG(customerBank.Id);
        String result1 = SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG(testAccount.Id);
        result1 = SyncCustomerInfoToMDGPro1.postCustomerInfomationToMDG(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testPostCustomerInfomationToMDG_CustomerAddress1() {
        // 获取测试账户
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account3' LIMIT 1];
        
        // 创建客户银行记录
        Customer_Banks__c customerBank = new Customer_Banks__c(
            Customer__c = testAccount.Id,
            Bank_Account__c = '123456789',
            Approval_Status__c = 'Approved',
            Bank_Code__c = '123456789', 
            Bank_Country__c='CN', 
            Bank_Name__c='Test', 
            Bank_name_local_language__c='Chinese'
        );
        insert customerBank;
        
        // 设置mock响应
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"INSTID":"testInstId","SYNSTATUS":"S","PARTNER":"12345678"}');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        String result1 = SyncCustomerInfoToMDGPro.postCustomerInfomationToMDG(testAccount.Id);
        result1 = SyncCustomerInfoToMDGPro1.postCustomerInfomationToMDG(testAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result1, 'Result should not be null');
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

    // 辅助方法：日期转字符串
    private static String dateToString(Date d) {
        return d.year() + String.valueOf(d.month()).leftPad(2, '0') + String.valueOf(d.day()).leftPad(2, '0');
    }
}