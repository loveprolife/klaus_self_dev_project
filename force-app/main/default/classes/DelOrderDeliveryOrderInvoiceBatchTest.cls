@isTest
private class DelOrderDeliveryOrderInvoiceBatchTest {
    static testMethod void testMethod1() {
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');

        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        Database.insert(mp1);
  
        Order__c order = new Order__c();
        order.Customer__c = accId;
        order.Order_Date__c = Date.valueOf('2020-01-01');
        order.Hisense_Entity__c = '8110';
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
        doi.Order__c = order.id;
        Database.insert(doi);
        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c = accId;
        Database.insert(invoice);
        Invoice_Item__c invoiceItem = new Invoice_Item__c();
        invoiceItem.Invoice__c = invoice.Id;
        invoiceItem.Sales_Order__c = order.id;
        invoiceItem.SAP_Product_Line__c = mp1.Id;
        invoiceItem.SAP_Product_Export_Model__c = 'TestExportModel5';
        invoiceItem.Sales_Order_Item__c = orderProduct.id;
        Database.insert(invoiceItem);

        Test.startTest();
        List<String> strlist = new List<String>();
        strlist.add('8110');
        DelOrderDeliveryOrderInvoiceBatch dpcrr = new DelOrderDeliveryOrderInvoiceBatch('2020-01-01','2020-01-02', strlist);
        Database.executeBatch(dpcrr,200);
        Test.stopTest();
    }
}