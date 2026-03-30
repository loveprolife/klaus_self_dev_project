@isTest
private class SAPGetInvoiceDateTest {
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

      Order__c order = new Order__c(
            Customer__c = accId,
            SAP_Order_No__c = '4500004397',
            External_Key__c = '45000043970000504263'
        );
        Database.insert(order);
        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.Order__c = order.Id;
        orderProduct.External_Key__c = '4500004397000010';
        Database.insert(orderProduct);
        Delivery_Order__c deliveryOrder = new Delivery_Order__c();
        deliveryOrder.Customer__c = accId;
        deliveryOrder.SAP_Delivery_Order_No__c = '0080002649';
        Database.insert(deliveryOrder);
        Delivery_Order_Item__c doi = new Delivery_Order_Item__c();
        doi.Delivery_Order__c = deliveryOrder.Id;
        doi.External_Key__c = '0080002649000010';
        Database.insert(doi);
        Test.startTest();
        String json = '{"OrderList": [{"InvoiceNo": "0090001582","InvoiceTotalAmount": "11896.00","InvoiceDate": "2016-10-24","SFCurrency": "ZAR","SAPCustomerCode": "0000504263","OrderLine": [{"InvoiceItemNo": "000010","SalesOrderNo": 4500004397,"SalesOrderItemNo": "000010","DeliveryOrderNo": "0080002649","DeliveryOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","InvoiceQuantity": "100.000","InvoiceAmount": "11896.00","ProductExportModel": "65M7000UWG","ProductLine": 62}]},{"InvoiceNo": "0090001583","InvoiceTotalAmount": "11896.00","InvoiceDate": "2016-10-24","SFCurrency": "ZAR","SAPCustomerCode": "0000504263","OrderLine": []}, {"InvoiceNo": "0090001584","InvoiceTotalAmount": "11896.00","InvoiceDate": "2016-10-24","SFCurrency": "ZAR","SAPCustomerCode": "0000504263","OrderLine": [{"InvoiceItemNo": "000010","SalesOrderNo": 4500004397,"SalesOrderItemNo": "000010","DeliveryOrderNo": "0080002649","DeliveryOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD1","ProductFactoryModel": "HA65M7000UWTG","InvoiceQuantity": "100.000","InvoiceAmount": "11896.00","ProductExportModel": "65M7000UWG","ProductLine": 14}]}, {"InvoiceNo": "0090001585","InvoiceTotalAmount": "11896.00","InvoiceDate": "2016-10-24","SFCurrency": "ZAR","SAPCustomerCode": "0000504262","OrderLine": [{"InvoiceItemNo": "000010","SalesOrderNo": 4500004397,"SalesOrderItemNo": "000010","DeliveryOrderNo": "0080002649","DeliveryOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","InvoiceQuantity": "100.000","InvoiceAmount": "11896.00","ProductExportModel": "65M7000UWG","ProductLine": 65}]}],"IsSuccess": "True","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        
        SAPGetInvoiceDate.getInvoiceFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }

    static testMethod void testMethod2(){
        TestDataUtility.createCustomSettings();
      Test.startTest();
      String json = '{"OrderList": [],"IsSuccess": "False","FailReason": ""}';
      Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetInvoiceDate.getInvoiceFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }

    static testMethod void testMethod3(){
        TestDataUtility.createCustomSettings();
      Test.startTest();
      String json = '{"OrderList": [],"IsSuccess" "False","FailReason": ""}';
      Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        List<String> companyList = new List<String>();
        companyList.add('8100');
        
        List<String> orderTypeCodeList = new List<String>();
        orderTypeCodeList.add('ZCR');
        SAPGetInvoiceDate.getInvoiceFromSAP(companyList,'2019-01-01','2019-01-01',orderTypeCodeList);
        Test.stopTest();
    }
}