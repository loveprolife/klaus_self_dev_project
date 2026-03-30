@isTest
private class SAPGetDeliveryOrderTest {
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
        String json = '{"OrderList": [{"DeliveryOrderNo": "0036195576","DeliveryOrderStatus": "未发货","ActualDeliveryDate": "","PODStatus": "未POD","SAPCustomerCode": "0000504263","OrderLine": [{"DeliveryOrderItemNo": "UUUUUU","SalesOrderNo": "0001000842","SalesOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","DeliveryQuantity": "5.000","DeliveryOrderItemStatus": "未发货","PODQuantity": "","PODReason": "","PODLineStatus": "未POD","PODDate": "","ProductExportModel": "65M7000UWG","ProductLine": 62,"IsDeleted": ""}]}, {"DeliveryOrderNo": "0087008740","DeliveryOrderStatus": "已发货","ActualDeliveryDate": "2018-10-28","PODStatus": "未POD","SAPCustomerCode": "0000504263","OrderLine": []}, {"DeliveryOrderNo": "0087009058","DeliveryOrderStatus": "已发货","ActualDeliveryDate": "2018-10-17","PODStatus": "未POD","SAPCustomerCode": "0000504263","OrderLine": [{"DeliveryOrderItemNo": "000010","SalesOrderNo": "0001001933","SalesOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD1","ProductFactoryModel": "HA65M7000UWTG","DeliveryQuantity": "10.000","DeliveryOrderItemStatus": "已发货","PODQuantity": "","PODReason": "","PODLineStatus": "未POD","PODDate": "","ProductExportModel": "65M7000UWG","ProductLine": 14,"IsDeleted": ""}]}, {"DeliveryOrderNo": "0087009059","DeliveryOrderStatus": "已发货","ActualDeliveryDate": "2018-10-19","PODStatus": "未POD","SAPCustomerCode": "0000504262","OrderLine": [{"DeliveryOrderItemNo": "000010","SalesOrderNo": "0001001936","SalesOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","DeliveryQuantity": "10.000","DeliveryOrderItemStatus": "已发货","PODQuantity": "","PODReason": "","PODLineStatus": "未POD","PODDate": "","ProductExportModel": "65M7000UWG","ProductLine": 65,"IsDeleted": ""}]}],"IsSuccess": "True","FailReason": ""}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetDeliveryOrder.getDeliveryOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }

    static testMethod void testMethod2(){
        TestDataUtility.createCustomSettings();
        String json1 = '{"OrderList": [],"IsSuccess": "False","FailReason": ""}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetDeliveryOrder.getDeliveryOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }

    static testMethod void testMethod3(){
        TestDataUtility.createCustomSettings();
        String json2 = '{"OrderList": [],"IsSuccess" "False","FailReason": ""}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json2));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetDeliveryOrder.getDeliveryOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }

    static testMethod void testMethod4(){
        TestDataUtility.createCustomSettings();
        String json3 = '{"OrderList": [{"DeliveryOrderNo": "0036195576","DeliveryOrderStatus": "未发货","ActualDeliveryDate": "2018-01-01","PODStatus": "未POD","SAPCustomerCode": "0000504263","OrderLine": [{"DeliveryOrderItemNo": "UUUUUU","SalesOrderNo": "0001000842","SalesOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","DeliveryQuantity": "5.000","DeliveryOrderItemStatus": "未发货","PODQuantity": "","PODReason": "","PODLineStatus": "未POD","PODDate": "2018-01-01","ProductExportModel": "65M7000UWG","ProductLine":"","IsDeleted": ""}]}],"IsSuccess": "True","FailReason": ""}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json3));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetDeliveryOrder.getDeliveryOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
    static testMethod void testMethod5(){
        TestDataUtility.createCustomSettings();
        String json3 = '{"OrderList": [{"DeliveryOrderNo": "0036195577","DeliveryOrderStatus": "未发货","ActualDeliveryDate": "2018-01-01","PODStatus": "未POD","SAPCustomerCode": "","OrderLine": [{"DeliveryOrderItemNo": "UUUUUU","SalesOrderNo": "0001000842","SalesOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","DeliveryQuantity": "5.000","DeliveryOrderItemStatus": "未发货","PODQuantity": "","PODReason": "","PODLineStatus": "未POD","PODDate": "2018-01-01","ProductExportModel": "65M7000UWG","ProductLine":"","IsDeleted": ""}]}],"IsSuccess": "True","FailReason": ""}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json3));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetDeliveryOrder.getDeliveryOrderFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
}