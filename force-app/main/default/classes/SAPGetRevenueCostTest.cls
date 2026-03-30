@isTest
private class SAPGetRevenueCostTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Mapping__c mpp = new Mapping__c();
        mpp.Name = '8500';
        mpp.Mapping_Code__c = '8500';
        mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        Database.insert(mpp);
        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp1);
        Mapping__c mpp2 = new Mapping__c();
        mpp1.Name = '0105';
        mpp1.Mapping_Code__c = 'WM';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp2);
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);
    	Test.startTest();
    	String json = '{"IsSuccess": "True","FailReason": "","FinanceInfoList": [{"CompanyCode": 8500,"Year": 2019,"Month": "04","BusinessScope": "0104","SAPCustomerCode": "0000504263","SFCurrency": "USD","SalesVolume": "0.000","SalesRevenue": "0.00","Cost": -23176.05},{"CompanyCode": 8500,"Year": 2019,"Month": "04","BusinessScope": "0105","SAPCustomerCode": "0000504263","SFCurrency": "USD","SalesVolume": "0.000","SalesRevenue": "0.00","Cost": -23176.05}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetRevenueCost.GetRevenueCostInfoFromSAP(companyList,'2019','01');
        Test.stopTest();
    }

    static testMethod void testMethod2(){
    	TestDataUtility.createCustomSettings();
    	Test.startTest();
    	String json = '{"IsSuccess": "False","FailReason": "","FinanceInfoList": []}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetRevenueCost.GetRevenueCostInfoFromSAP(companyList,'2019','01');
        Test.stopTest();
    }

    static testMethod void testMethod3(){
    	TestDataUtility.createCustomSettings();
    	Test.startTest();
    	String json = '{"IsSuccess": "False","FailReason" "","FinanceInfoList": []}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetRevenueCost.GetRevenueCostInfoFromSAP(companyList,'2019','01');
        Test.stopTest();
    }

    static testMethod void testMethod4(){
    	TestDataUtility.createCustomSettings();
    	ID accId = TestDataUtility.createAccount('TestAccount 1', 'MC-RC-ATX01', 'MC-RC-ATX01','Hisense USA');
    	Test.startTest();
    	String json = '{"IsSuccess": "True","FailReason": "","FinanceInfoList": [{"CompanyCode": 8500,"Year": 2019,"Month": "04","BusinessScope": "0104","SAPCustomerCode": "","SFCurrency": "ZAR","SalesVolume": "0.000","SalesRevenue": "0.00","Cost": -23176.05}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetRevenueCost.GetRevenueCostInfoFromSAP(companyList,'2019','01');
        Test.stopTest();
    }
}