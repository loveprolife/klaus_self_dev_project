@isTest
private class CustomerButtonHandlerControllerTest {
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
        TestDataUtility.createCustomSettings();
        List<User> userList = TestDataUtility.createUserList(true);
        Account acc = new Account();
        acc.Name = 'Test Customer0011';
        acc.Approval_Status__c = 'Draft';
        acc.SAP_Customer_Code__c = 'SAPCode7512';
        insert acc;
        Test.startTest();
        CustomerButtonHandlerController.getCustomerCreditLimit(acc.Id);
        //只有审批通过的客户才能同步到SAP
        CustomerButtonHandlerController.syncCustomerToSAP(acc.Id);
        acc.Approval_Status__c = 'Approved';
        update acc;
        //客户已经同步到SAP
        CustomerButtonHandlerController.syncCustomerToSAP(acc.Id);
        acc.SAP_Customer_Code__c = null;
        update acc;
        CustomerButtonHandlerController.syncCustomerToSAP(acc.Id);
        //获取信用额度先同步客户到SAP
        CustomerButtonHandlerController.getCustomerCreditLimit(acc.Id);
        Test.stopTest();
        
    }
    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();
        List<User> userList = TestDataUtility.createUserList(true);
        Account acc = new Account();
        acc.Name = 'Test Customer0011';
        acc.Approval_Status__c = 'Draft';
        acc.SAP_Customer_Code__c = 'SAPCode7512';
        insert acc;
        Test.startTest();
        //没有权限同步客户到SAP 
        System.debug('userList[1]: ' +userList[1]);
        System.runAs(userList[1]){
            CustomerButtonHandlerController.syncCustomerToSAP(acc.Id);
        }
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        TestDataUtility.createCustomSettings();
        List<User> userList = TestDataUtility.createUserList(true);
        Account acc = new Account();
        acc.Name = 'Test Customer0011';
        acc.Approval_Status__c = 'Draft';
        acc.SAP_Customer_Code__c = 'SAPCode7512';
        insert acc;
        Customer_Extend__c ce = new Customer_Extend__c();
        ce.Customer__c = acc.id;
        ce.Approval_Status__c = 'Draft';
        ce.Show_Company__c = true;
        ce.Show_Sales__c = true;
        insert ce;
        Test.startTest();
        CustomerButtonHandlerController.getRecordIdType(ce.Id);
        //只有审批通过的客户才能同步到SAP
        CustomerButtonHandlerController.syncCustomerToSAP(ce.Id);
        ce.Approval_Status__c = 'Approved';
        update ce;
        //客户已经同步到SAP
        CustomerButtonHandlerController.syncCustomerToSAP(ce.Id);
        acc.SAP_Customer_Code__c = null;
        update acc;
        CustomerButtonHandlerController.syncCustomerToSAP(ce.Id);
        Test.stopTest();
        
    }
}