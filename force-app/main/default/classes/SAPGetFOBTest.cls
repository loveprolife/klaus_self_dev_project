@isTest
private class SAPGetFOBTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        Test.startTest();

        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
    	Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
    	customerProductLine.Product_Line_Name__c = 'TV';
    	customerProductLine.Customer__c = accId;
    	customerProductLine.Management_Customer__c = accId;
    	customerProductLine.Classification__c = 'Customer of Oversea Company';
    	customerProductLine.Development_Stage__c = 'Undeveloped';
    	customerProductLine.Prospective_Rank__c = 'Normal Customer';
    	Database.insert(customerProductLine);
    	Order__c order = new Order__c();
        order.Customer__c = accId;
        order.Purchase_Order_No__c = '123123123';
    	Database.insert(order);
    	Order_Product__c orderProduct = new Order_Product__c();
    	orderProduct.Order__c = order.Id;
    	Database.insert(orderProduct);

        
        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c = accId;
        insert invoice;

        String json = '{"FOBDataList":[{"GTMShippingOrder":"0001004111","SalesDocumentItem":"000010","Orderstatus":"E0005","Customer":"0000504263","CustomerName":"sadfasd","ExternalDocumentNumber":"8110-300730","BatchNumber":"BKA01","Division":"Appliances-REF","Brand":"HISENSE","ShipsName":"COSCO-0007","BLNO":9346578460,"ActualShipDate":"0000-00-00","ProductionBase":"Hisense Rongsheng Ltd.","FOBPort":"RONGQI","DestinationPort":"SHELBY, IA","RequestedShipDate":"2021-11-04","RequestedDeliveryDate":"2021-11-14","EstimatedArrivalDate":"2021-11-21","ShippingCompany":"COSCO","POnumber":"123123123","CustomerModel":"RB320D4WB1","USAItemNumber":1004111,"POQty":"100.000","DestinationDC":4111,"SAPInvoiceDate":"0000-00-00","BillingDocument":"","Billingitem":"000000","InvoicePriceByUnit":0,"InvoicePriceByContainer":0},{"GTMShippingOrder":"0001004111","SalesDocumentItem":"000020","Orderstatus":"E0005","Customer":"0000502970","CustomerName":"sadfasd","ExternalDocumentNumber":"8110-300730","BatchNumber":"BKA02","Division":"Appliances-REF","Brand":"HISENSE","ShipsName":"COSCO-0007","BLNO":9346578460,"ActualShipDate":"0000-00-00","ProductionBase":"Hisense Rongsheng Ltd.","FOBPort":"RONGQI","DestinationPort":"SHELBY, IA","RequestedShipDate":"2021-11-04","RequestedDeliveryDate":"2021-11-14","EstimatedArrivalDate":"2021-11-21","ShippingCompany":"COSCO","POnumber":"PO1004111","CustomerModel":"HR6BF121","USAItemNumber":1004111,"POQty":"100.000","DestinationDC":4111,"SAPInvoiceDate":"0000-00-00","BillingDocument":"","Billingitem":"000000","InvoicePriceByUnit":0,"InvoicePriceByContainer":0}],"IsSuccess":"S","FailReason":"数据查询成功"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SAPGetFOB.getFOBFromSAP('20210926');
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"FOBDataList":[],"IsSuccess":"false","FailReason":""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SAPGetFOB.getFOBFromSAP('20210926');
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"FOBDataList":[{"GTMShippingOrder":"0001004111","SalesDocumentItem":"000010","Orderstatus":"E0005","Customer":"0000502970","CustomerName":"sadfasd","ExternalDocumentNumber":"8110-300730","BatchNumber":"BKA01","Division":"Appliances-REF","Brand":"HISENSE","ShipsName":"COSCO-0007","BLNO":9346578460,"ActualShipDate":"0000-00-00","ProductionBase":"Hisense Rongsheng Ltd.","FOBPort":"RONGQI","DestinationPort":"SHELBY, IA","RequestedShipDate":"2021-11-04","RequestedDeliveryDate":"2021-11-14","EstimatedArrivalDate":"2021-11-21","ShippingCompany":"COSCO","POnumber":"PO1004111","CustomerModel":"RB320D4WB1","USAItemNumber":1004111,"POQty":"100.000","DestinationDC":4111,"SAPInvoiceDate":"0000-00-00","BillingDocument":"","Billingitem":"000000","InvoicePriceByUnit":0,"InvoicePriceByContainer":0},{"GTMShippingOrder":"0001004111","SalesDocumentItem":"000010","Orderstatus":"E0005","Customer":"0000502970","CustomerName":"sadfasd","ExternalDocumentNumber":"8110-300730","BatchNumber":"BKA02","Division":"Appliances-REF","Brand":"HISENSE","ShipsName":"COSCO-0007","BLNO":9346578460,"ActualShipDate":"0000-00-00","ProductionBase":"Hisense Rongsheng Ltd.","FOBPort":"RONGQI","DestinationPort":"SHELBY, IA","RequestedShipDate":"2021-11-04","RequestedDeliveryDate":"","EstimatedArrivalDate":"2021-11-21","ShippingCompany":"COSCO","POnumber":"PO1004111","CustomerModel":"HR6BF121","USAItemNumber":1004111,"POQty":"100.000","DestinationDC":4111,"SAPInvoiceDate":"0000-00-00","BillingDocument":"","Billingitem":"000000","InvoicePriceByUnit":0,"InvoicePriceByContainer":0}],"IsSuccess":"S","FailReason":"数据查询成功"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SAPGetFOB.getFOBFromSAP('20210926');
        Test.stopTest();
    }

    static testMethod void testMethod4() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '{"FOBDataList":[{"GTMShippingOrder":"0001004111","SalesDocumentItem":"000010","Orderstatus":"E0005","Customer":"0000502970","CustomerName":"sadfasd","ExternalDocumentNumber":"8110-300730","BatchNumber":"BKA01","Division":"Appliances-REF","Brand":"HISENSE","ShipsName":"COSCO-0007","BLNO":9346578460,"ActualShipDate":"0000-00-00","ProductionBase":"Hisense Rongsheng Ltd.","FOBPort":"RONGQI","DestinationPort":"SHELBY, IA","RequestedShipDate":"2021-11-04","RequestedDeliveryDate":"0000-00-00","EstimatedArrivalDate":"2021-11-21","ShippingCompany":"COSCO","POnumber":"PO1004111","CustomerModel":"RB320D4WB1","USAItemNumber":1004111,"POQty":"100.000","DestinationDC":4111,"SAPInvoiceDate":"0000-00-00","BillingDocument":"","Billingitem":"000000","InvoicePriceByUnit":0,"InvoicePriceByContainer":0},{"GTMShippingOrder":"0001004111","SalesDocumentItem":"000020","Orderstatus":"E0005","Customer":"0000502970","CustomerName":"sadfasd","ExternalDocumentNumber":"8110-300730","BatchNumber":"BKA02","Division":"Appliances-REF","Brand":"HISENSE","ShipsName":"COSCO-0007","BLNO":9346578460,"ActualShipDate":"0000-00-00","ProductionBase":"Hisense Rongsheng Ltd.","FOBPort":"RONGQI","DestinationPort":"SHELBY, IA","RequestedShipDate":"2021-11-04","RequestedDeliveryDate":"2021-11-14","EstimatedArrivalDate":"2021-11-21","ShippingCompany":"COSCO","POnumber":"PO1004111","CustomerModel":"HR6BF121","USAItemNumber":1004111,"POQty":"100.000","DestinationDC":4111,"SAPInvoiceDate":"0000-00-00","BillingDocument":"","Billingitem":"000000","InvoicePriceByUnit":0,"InvoicePriceByContainer":"aa"}],"IsSuccess":"S","FailReason":"数据查询成功"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SAPGetFOB.getFOBFromSAP('20210926');
        Test.stopTest();
    }

    
    static testMethod void testMethod5() {
        TestDataUtility.createCustomSettings();
        Test.startTest();
        String json = '';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SAPGetFOB.getFOBFromSAP('20210926');
        Test.stopTest();
    }
}