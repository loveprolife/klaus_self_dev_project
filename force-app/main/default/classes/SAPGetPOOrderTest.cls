@isTest
private class SAPGetPOOrderTest {
    static testMethod void testMethod1() {
    	TestDataUtility.createCustomSettings();
    	ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
    	TestDataUtility.createCustomerModelProduct('H359BI-WD', null,null);
    	TestDataUtility.createCustomerModelProduct('H359BI-WD1', 'Hisense USA','TV');
    	//Cooking用出口型号
    	TestDataUtility.createProduct('65M7000UWG');
    	//电视  手机用工厂型号
    	TestDataUtility.createProduct('HA65M7000UWTG');
    	//冰冷洗用工厂型号建relation
    	TestDataUtility.createProductRelation('HA65M7000UWTG');

    	//添加产品线
    	TestDataUtility.insertMapping('62','Refrigerator');
    	TestDataUtility.insertMapping('65', 'Cooking');
    	TestDataUtility.insertMapping('14', 'TV');
    	Test.startTest();
        String json = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "0000504263","OrderStatus": "待处理","OrderAmount": "493350.00","SFCurrency": "ZAR","OrderDate": "2019-05-10","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","HisenseEntity": 8510,"OrderLine": [{"SAPOrderItemNo": 1,"ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "3289.00","Quantity": "150.000","TotalSalesAmount": "493350.00","PlannedDeliveryDate": "2019-05-17","SAPProductLine": 62,"ProductExportModel": "65M7000UWG","MaterialNumber": ""}]}, {"SAPOrderNo": "0036195577","SAPCustomerCode": "0000504263","OrderStatus": "待处理","OrderAmount": "493350.00","SFCurrency": "ZAR","OrderDate": "2019-05-10","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","HisenseEntity": 8510,"OrderLine": []}, {"SAPOrderNo": "0036195578","SAPCustomerCode": "0000504263","OrderStatus": "待处理","OrderAmount": "493350.00","SFCurrency": "ZAR","OrderDate": "2019-05-10","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","HisenseEntity": 8510,"OrderLine": [{"SAPOrderItemNo": 1,"ProductCustomerModel": "H359BI-WD1","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "3289.00","Quantity": "150.000","TotalSalesAmount": "493350.00","PlannedDeliveryDate": "2019-05-17","SAPProductLine": 14,"ProductExportModel": "65M7000UWG","MaterialNumber": ""}]}, {"SAPOrderNo": "0036195579","SAPCustomerCode": "0000504262","OrderStatus": "待处理","OrderAmount": "493350.00","SFCurrency": "ZAR","OrderDate": "2019-05-10","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","HisenseEntity": 8510,"OrderLine": [{"SAPOrderItemNo": 1,"ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "3289.00","Quantity": "150.000","TotalSalesAmount": "493350.00","PlannedDeliveryDate": "2019-05-17","SAPProductLine": 65,"ProductExportModel": "65M7000UWG","MaterialNumber": ""}]}],"IsSuccess": "True","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetPOOrder.getPOOrderFromSAP(companyList);
        Test.stopTest();
    }

    static testMethod void testMethod2(){
    	TestDataUtility.createCustomSettings();
    	String json1 = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "0000504263","OrderStatus": "待处理","OrderAmount": "493350.00","SFCurrency": "ZAR","OrderDate": "","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","HisenseEntity": 8510,"OrderLine": [{"SAPOrderItemNo": 1,"ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "3289.00","Quantity": "150.000","TotalSalesAmount": "493350.00","PlannedDeliveryDate": "","SAPProductLine": "","ProductExportModel": "65M7000UWG","MaterialNumber": ""}]}],"IsSuccess": "True","FailReason": ""}';
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetPOOrder.getPOOrderFromSAP(companyList);
        Test.stopTest();
    }

    static testMethod void testMethod3(){
    	TestDataUtility.createCustomSettings();
    	String json2 = '{"OrderList": [],"IsSuccess": "False","FailReason": ""}';
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json2));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetPOOrder.getPOOrderFromSAP(companyList);
        Test.stopTest();
    }

    static testMethod void testMethod4(){
    	TestDataUtility.createCustomSettings();
    	String json3 = '{"OrderList" [],"IsSuccess": "False","FailReason": ""}';
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json3));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetPOOrder.getPOOrderFromSAP(companyList);
        Test.stopTest();
    }
    static testMethod void testMethod5(){
        TestDataUtility.createCustomSettings();
        String json1 = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "","OrderStatus": "待处理","OrderAmount": "493350.00","SFCurrency": "ZAR","OrderDate": "","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","HisenseEntity": 8510,"OrderLine": [{"SAPOrderItemNo": 1,"ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "3289.00","Quantity": "150.000","TotalSalesAmount": "493350.00","PlannedDeliveryDate": "","SAPProductLine": "","ProductExportModel": "65M7000UWG","MaterialNumber": ""}]}],"IsSuccess": "True","FailReason": ""}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        SAPGetPOOrder.getPOOrderFromSAP(companyList);
        Test.stopTest();
    }
}