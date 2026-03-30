@isTest
private class SAPGetSalesOrderTest {
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
        String json = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 62,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]},{"SAPOrderNo": "0036195577","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": []},{"SAPOrderNo": "0036195578","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD1","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 14,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]},{"SAPOrderNo": "0036195579","SAPCustomerCode": "0000504262","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 65,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]}],"IsSuccess": "True","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        
        SAPGetSalesOrder.getSalesOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
    static testMethod void testMethod2(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 62,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]},{"SAPOrderNo": "0036195577","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": []},{"SAPOrderNo": "0036195578","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD1","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 14,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]},{"SAPOrderNo": "0036195579","SAPCustomerCode": "0000504262","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 65,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]}],"IsSuccess": "False","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetSalesOrder.getSalesOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
    static testMethod void testMethod3(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode""0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 62,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]},{"SAPOrderNo": "0036195577","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": []},{"SAPOrderNo": "0036195578","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD1","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 14,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]},{"SAPOrderNo": "0036195579","SAPCustomerCode": "0000504262","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "2019-03-31","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "2019-03-31","SAPProductLine": 65,"ProductExportModel": "65M7000UWG","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]}],"IsSuccess": "False","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetSalesOrder.getSalesOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
    static testMethod void testMethod4(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "0000504263","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "BCD-269AHC2(HAB1)","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "","SAPProductLine":"","ProductExportModel": "BCD-269AHC2(HAB1)","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]}],"IsSuccess": "True","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetSalesOrder.getSalesOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
    static testMethod void testMethod5(){
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"OrderList": [{"SAPOrderNo": "0036195576","SAPCustomerCode": "","OrderStatus": "审批通过","OrderAmount": "370.00","SFCurrency": "USD","OrderDate": "","OrderTypeCode": "ZOR4","OrderTypeName": "HSII OTS SO","PurchaseOrderNo": "HSEK180801HL.5","VirtualOrderNo": "","HisenseEntity": 8500,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "BCD-269AHC2(HAB1)","UnitPrice": "185.00","Quantity": "2.000","TotalSalesAmount": "370.00","PlannedDeliveryDate": "","SAPProductLine":"","ProductExportModel": "BCD-269AHC2(HAB1)","IsDeleted": "","MaterialNumber": "1B0269Z0009JBF3NX"}]}],"IsSuccess": "True","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetSalesOrder.getSalesOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
}