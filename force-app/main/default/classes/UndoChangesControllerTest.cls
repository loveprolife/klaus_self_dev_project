@isTest
private class UndoChangesControllerTest {
    
    @testSetup
    static void setup() {
        // 创建必要的自定义设置记录
        MDG_Interface__c mdgInterface = new MDG_Interface__c(
            Name = 'CustomerMaintain',
            Url__c = 'https://test.url',
            AppId__c = 'testAppId',
            ClientId__c = '300',
            If_Id__c = 'Customer_maintain',
            SecretKey__c = 'testSecretKey',
            PCOMPANY__c = 'testCompany'
        );
        insert mdgInterface;
        
        //RecordType
        RecordType subAccountRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Sub Account' LIMIT 1];
        
        // 创建测试账户1
        Account testAccount = new Account(
            Name = 'Test Account',
            Customer_Name_Local_Language__c = '测试账户',
            Customer_Short_Name__c = 'TA',
            Phone = '1234567890',
            Trader_Type__c = 'H001',
            CustomerDetailType__c = '10',
            Guarantor_Country_Code__c = 'CN',
            Hisense_Entity__c = '0000',
            Hisense_Entity_Sales__c = '0000',
            E_commerce_Customer_Label__c = '10',
            RecordTypeId = subAccountRecordType.Id
        );
        insert testAccount;
        
        // 创建测试账户2
        Account testAccount2 = new Account(
            Name = 'Test Account2',
            Customer_Name_Local_Language__c = '测试账户2',
            Customer_Short_Name__c = 'TA2',
            Phone = '1234567890',
            Trader_Type__c = 'H002',
            CustomerDetailType__c = '10',
            E_commerce_Customer_Label__c = '10',
            Guarantor_Country_Code__c = 'CN'
        );
        insert testAccount2;

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

    static testmethod void test() {

        Test.startTest();

        // 获取测试账户
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        //RecordType
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'customer' LIMIT 1];
        
        acc1.RecordTypeId = customerRecordType.Id;
        update acc1;
        
        // 创建客户扩展记录
        Customer_Extend__c customerExtend = new Customer_Extend__c(
            Customer__c = acc1.Id,
            E_commerce_Customer_Label__c = '10',
            Show_Company__c = True,
            Show_Sales__c = True,
            Hisense_Entity__c = '8010',
            Hisense_Entity_Sales__c = '8010',
            Payment_Term__c = [SELECT Id FROM Payment_Term__c LIMIT 1].Id
        );
        insert customerExtend;

        MDG_Bank__c mb = new MDG_Bank__c();
        mb.External_Key__c = '123';
        mb.BANKS__c = 'US';
        mb.BANKA__c = '123';
        mb.BANKL__c = '123';
        mb.ZQSBM__c = '123';
        insert mb;

        Customer_Banks__c ce = new Customer_Banks__c();
        ce.Customer__c = acc1.id;
        ce.Bank_Country__c = 'US';
        ce.Bank_Account__c = '123';
        ce.Approval_Status__c = 'Draft';
        ce.Bank_name_local_language__c = '123';
        ce.MDG_Bank__c = mb.Id;
        Database.insert(ce);

        Customer_Address__c ca = new Customer_Address__c();
        ca.Name = 'testca';
        ca.Customer__c = acc1.Id;
        ca.Email__c = '3333@qq.com';
        insert ca;

        UndoChangesController.initData(acc1.Id);

        Customer_Extend_Bank_History__c cebh = new Customer_Extend_Bank_History__c();
        cebh.Record_id__c = acc1.Id;
        cebh.Record_type__c = 'Account';
        cebh.Record_body__c = JSON.serialize(acc1);
        cebh.New_record_body__c = JSON.serialize(acc1);
        cebh.Process_cause__c = '变更';
        
        insert cebh;

        UndoChangesController.initData(acc1.Id);

        Customer_Extend_Bank_History__c cebh1 = new Customer_Extend_Bank_History__c();
        cebh1.Record_id__c = customerExtend.Id;
        cebh1.Record_type__c = 'Customer_Extend__c';
        cebh1.Record_body__c = JSON.serialize(customerExtend);
        cebh1.New_record_body__c = JSON.serialize(customerExtend);
        cebh1.Process_cause__c = '变更';
        
        insert cebh1;

        UndoChangesController.initData(customerExtend.Id);

        Customer_Extend_Bank_History__c cebh2 = new Customer_Extend_Bank_History__c();
        cebh2.Record_id__c = ce.Id;
        cebh2.Record_type__c = 'Customer_Banks__c';
        cebh2.Record_body__c = JSON.serialize(ce);
        cebh2.New_record_body__c = JSON.serialize(ce);
        cebh2.Process_cause__c = '变更';
        
        insert cebh2;

        UndoChangesController.initData(ce.Id);

        Test.stopTest();
    }
 
}