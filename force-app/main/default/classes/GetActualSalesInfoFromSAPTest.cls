/*
 * @Author: WFC
 * @Date: 2022-07-12 10:45:58
 * @LastEditors: WFC
 * @LastEditTime: 2022-07-12 12:07:18
 * @Description: 
 * @FilePath: \Hitest\force-app\main\default\classes\GetActualSalesInfoFromSAPTest.cls
 */
@isTest
private class GetActualSalesInfoFromSAPTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Account acc = new Account(
                            Name = 'testname',
                            SAP_Customer_Code__c = '0005001234');
        insert acc;

        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        insert mp1;

        Mapping__c mp2 = new Mapping__c();
        mp2.Name = '001';
        mp2.Mapping_Code__c = 'USA';
        mp2.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        insert mp2;

        Customer_Model_Product__c cmp = new Customer_Model_Product__c();
        cmp.name = 'cmp001';
        cmp.ExternalId__c = 'cmp001001';
        insert cmp;

        Customer_Product_Line__c cpl = new Customer_Product_Line__c();
        cpl.Product_Line_Name__c = 'TV';
        cpl.Customer__c = acc.Id;
        cpl.Product_Line_External_Key__c = '0005001234TV';
        insert cpl;

        Product__c pd = new Product__c();
        pd.name = 'pd001';
        insert pd;

        Order__c order = new Order__c();
    	order.Customer__c = acc.Id;
    	insert(order);
        Order_Product__c op = new Order_Product__c();
        op.External_Key__c = 'po001on0010005001234';
        op.Order__c = order.Id;
        insert op;

        Delivery_Order__c deo = new Delivery_Order__c();
        deo.Customer__c = acc.Id;
        deo.SAP_Delivery_Order_No__c = 'do001';
        insert deo;

        Invoice__c ic = new Invoice__c();
        ic.SAP_Invoice_No__c = 'io001';
        ic.Customer__c = acc.Id;
        insert ic;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ActualSalesInfoList":[{"CustomerModel": "cmp001","CustomerSAPCode": "0005001234","FactoryModel": "pd001","ExportModel": "pd002","OrderCategory": "E","PONo": "po001","OrderItemNo": "on001","DNNo": "do001","InvoiceNo": "io001","ProductLineCode": "14","SalesOrganization": "001","SFCurrency": "USDD","UnitPrice": "100","SOQty": "10","BackOrderAmount": "10","BackOrderQty": "10" '+
                        ' ,"DNQty": "10","ShipAmount": "10","PendingDNQty": "10","PendingDNAmount": "10","PODNumber": "10","InvoicedQty": "10","InvoicedAmount": "10","DNNetIncome": "10","Cost": "10","BackOrderNetIncome": "10","PendingDNNetIncome": "10","InvoiceNetIncome": "10","InvoiceDate": "2022-01-01","DeliveryOrderPostingDate": "2022-01-01"}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetActualSalesInfoFromSAP.adoPost(); 
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Test.startTest();
        Account acc = new Account(
                            Name = 'testname',
                            SAP_Customer_Code__c = '0005001234');
        insert acc;

        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        insert mp1;

        Mapping__c mp2 = new Mapping__c();
        mp2.Name = '001';
        mp2.Mapping_Code__c = 'USA';
        mp2.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        insert mp2;

        Customer_Model_Product__c cmp = new Customer_Model_Product__c();
        cmp.name = 'cmp001';
        cmp.ExternalId__c = 'cmp001001';
        insert cmp;

        Customer_Product_Line__c cpl = new Customer_Product_Line__c();
        cpl.Product_Line_Name__c = 'TV';
        cpl.Customer__c = acc.Id;
        cpl.Product_Line_External_Key__c = '0005001234TV';
        insert cpl;

        Product__c pd = new Product__c();
        pd.name = 'pd001';
        insert pd;

        Order__c order = new Order__c();
    	order.Customer__c = acc.Id;
    	insert(order);
        Order_Product__c op = new Order_Product__c();
        op.External_Key__c = 'po001on0010005001234';
        op.Order__c = order.Id;
        insert op;

        Delivery_Order__c deo = new Delivery_Order__c();
        deo.Customer__c = acc.Id;
        deo.SAP_Delivery_Order_No__c = 'do001';
        insert deo;

        Invoice__c ic = new Invoice__c();
        ic.SAP_Invoice_No__c = 'io001';
        ic.Customer__c = acc.Id;
        insert ic;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ActualSalesInfoList":[{"CustomerModel": "cmp001","CustomerSAPCode": "0005001234","FactoryModel": "pd001","ExportModel": "pd002","OrderCategory": "S","PONo": "po001","OrderItemNo": "on001","DNNo": "do001","InvoiceNo": "io001","ProductLineCode": "14","SalesOrganization": "001","SFCurrency": "USD","UnitPrice": "100","SOQty": "10","BackOrderAmount": "10","BackOrderQty": "10" '+
                        ' ,"DNQty": "10","ShipAmount": "10","PendingDNQty": "10","PendingDNAmount": "10","PODNumber": "10","InvoicedQty": "10","InvoicedAmount": "10","DNNetIncome": "10","Cost": "10","BackOrderNetIncome": "10","PendingDNNetIncome": "10","InvoiceNetIncome": "10","InvoiceDate": "0","DeliveryOrderPostingDate": "0"}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetActualSalesInfoFromSAP.adoPost(); 
        Test.stopTest();
    }
    

    static testMethod void testMethod7() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ActualSalesInfoList":[{"CustomerModel": "cmp001","CustomerSAPCode": "0005001234","FactoryModel": "pd001","ExportModel": "pd002","OrderCategory": "S","PONo": "po001","OrderItemNo": "on001","DNNo": "do001","InvoiceNo": "io001","ProductLineCode": "14","SalesOrganization": "001","SFCurrency": "USD","UnitPrice": "100","SOQty": "10","BackOrderAmount": "10","BackOrderQty": "10" '+
        ' ,"DNQty": "10","ShipAmount": "10","PendingDNQty": "10","PendingDNAmount": "10","PODNumber": "10","InvoicedQty": "10","InvoicedAmount": "10","DNNetIncome": "10","Cost": "10","BackOrderNetIncome": "10","PendingDNNetIncome": "10","InvoiceNetIncome": "10","InvoiceDate": "0","DeliveryOrderPostingDate": ""}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetActualSalesInfoFromSAP.adoPost(); 
        Test.stopTest();
    }

    
    static testMethod void testMethod8() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ActualSalesInfoList":[]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetActualSalesInfoFromSAP.adoPost(); 
        Test.stopTest();
    }

    static testMethod void testMethod9() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"ActualSalesInfo":[{]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetActualSalesInfoFromSAP.adoPost(); 
        Test.stopTest();
    }
   
}