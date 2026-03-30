@isTest
private class GetGSSInventoryReportTest {

    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = '0002000101',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        insert acc1;
        String jsonStr = '{"InventoryDataList":[{"Id":1,"CustomerSAPCode":2000101,"ProductionBase":"江门","ProductCategory":"冰箱","ProductType":"外机","BatchNumber":"KC2SH","SalesBigArea":"欧洲区","SalesSmallArea":"海外公司－西班牙公司","CustomerName":"Hisense Iberia S.L.U.","Brand":"HISENSE","FactoryModel":"+AS-12UW4RYRKG03(HSN\\/ES)","OrderCount":700,"StockInCount":700,"FirstStockInDate":"2021-05-07","CycleTime":5,"CurrentDate":"2021-05-08","LastStockInDate":"2021-05-08","ScheduledShippingTime":"2021-05-13 00:00:00","PartialShippingTime":"","StorageCount":0,"StockAge":0,"Employee":"邹新竹","SalesCoordinator":"侯昱勐","ProductState":"期限内库存","CustomerModel":"","ContractNumber":"","ShippingOrderNumber":"","OverdueReason":"","DisposalMeasures":"","EstimatedBillOfLadingDate":"","ResponsiblePerson":"国际营销","Remark":""},{"Id":1,"CustomerSAPCode":2000101,"ProductionBase":"江门","ProductCategory":"电视","ProductType":"外机","BatchNumber":"KC2SJ","SalesBigArea":"欧洲区","SalesSmallArea":"海外公司－西班牙公司","CustomerName":"Hisense Iberia S.L.U.","Brand":"HISENSE","FactoryModel":"+AS-12UW4RYRKB03(HSN\\/ES)","OrderCount":1400,"StockInCount":1400,"FirstStockInDate":"2021-05-07","CycleTime":4,"CurrentDate":"2021-05-09","LastStockInDate":"2021-05-11","ScheduledShippingTime":"2021-05-13 00:00:00","PartialShippingTime":"","StorageCount":0,"StockAge":-1,"Employee":"邹新竹","SalesCoordinator":"侯昱勐","ProductState":"期限内库存","CustomerModel":"","ContractNumber":"","ShippingOrderNumber":"","OverdueReason":"","DisposalMeasures":"","EstimatedBillOfLadingDate":"","ResponsiblePerson":"工厂","Remark":""},{"Id":1,"CustomerSAPCode":2000101,"ProductionBase":"江门","ProductCategory":"冷柜","ProductType":"外机","BatchNumber":"KC2SH","SalesBigArea":"欧洲区","SalesSmallArea":"海外公司－西班牙公司","CustomerName":"Hisense Iberia S.L.U.","Brand":"HISENSE","FactoryModel":"+AS-12UW4RYRKG03(HSN\\/ES)","OrderCount":700,"StockInCount":700,"FirstStockInDate":"2021-05-07","CycleTime":5,"CurrentDate":"2021-05-08","LastStockInDate":"2021-05-08","ScheduledShippingTime":"2021-05-13 00:00:00","PartialShippingTime":"","StorageCount":0,"StockAge":0,"Employee":"邹新竹","SalesCoordinator":"侯昱勐","ProductState":"期限内库存","CustomerModel":"","ContractNumber":"","ShippingOrderNumber":"","OverdueReason":"","DisposalMeasures":"","EstimatedBillOfLadingDate":"","ResponsiblePerson":"国际营销","Remark":""},{"Id":1,"CustomerSAPCode":2000101,"ProductionBase":"江门","ProductCategory":"空调","ProductType":"外机","BatchNumber":"KC2SJ","SalesBigArea":"欧洲区","SalesSmallArea":"海外公司－西班牙公司","CustomerName":"Hisense Iberia S.L.U.","Brand":"HISENSE","FactoryModel":"+AS-12UW4RYRKB03(HSN\\/ES)","OrderCount":1400,"StockInCount":1400,"FirstStockInDate":"2021-05-07","CycleTime":4,"CurrentDate":"2021-05-09","LastStockInDate":"2021-05-11","ScheduledShippingTime":"2021-05-13 00:00:00","PartialShippingTime":"","StorageCount":0,"StockAge":-1,"Employee":"邹新竹","SalesCoordinator":"侯昱勐","ProductState":"期限内库存","CustomerModel":"","ContractNumber":"","ShippingOrderNumber":"","OverdueReason":"","DisposalMeasures":"","EstimatedBillOfLadingDate":"","ResponsiblePerson":"工厂","Remark":""},{"Id":1,"CustomerSAPCode":2000101,"ProductionBase":"江门","ProductCategory":"洗衣机","ProductType":"外机","BatchNumber":"KC2SH","SalesBigArea":"欧洲区","SalesSmallArea":"海外公司－西班牙公司","CustomerName":"Hisense Iberia S.L.U.","Brand":"HISENSE","FactoryModel":"+AS-12UW4RYRKG03(HSN\\/ES)","OrderCount":700,"StockInCount":700,"FirstStockInDate":"2021-05-07","CycleTime":5,"CurrentDate":"2021-05-08","LastStockInDate":"2021-05-08","ScheduledShippingTime":"2021-05-13 00:00:00","PartialShippingTime":"","StorageCount":0,"StockAge":0,"Employee":"邹新竹","SalesCoordinator":"侯昱勐","ProductState":"期限内库存","CustomerModel":"","ContractNumber":"","ShippingOrderNumber":"","OverdueReason":"","DisposalMeasures":"","EstimatedBillOfLadingDate":"","ResponsiblePerson":"国际营销","Remark":""},{"Id":1,"CustomerSAPCode":2000101,"ProductionBase":"江门","ProductCategory":"空调1","ProductType":"外机","BatchNumber":"KC2SJ","SalesBigArea":"欧洲区","SalesSmallArea":"海外公司－西班牙公司","CustomerName":"Hisense Iberia S.L.U.","Brand":"HISENSE","FactoryModel":"+AS-12UW4RYRKB03(HSN\\/ES)","OrderCount":1400,"StockInCount":1400,"FirstStockInDate":"2021-05-07","CycleTime":4,"CurrentDate":"2021-05-09","LastStockInDate":"2021-05-11","ScheduledShippingTime":"2021-05-13 00:00:00","PartialShippingTime":"","StorageCount":0,"StockAge":-1,"Employee":"邹新竹","SalesCoordinator":"侯昱勐","ProductState":"期限内库存","CustomerModel":"","ContractNumber":"","ShippingOrderNumber":"","OverdueReason":"","DisposalMeasures":"","EstimatedBillOfLadingDate":"","ResponsiblePerson":"工厂","Remark":""}]}';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetGSSInventoryReport.adoPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"InventoryAgingList": []}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetGSSInventoryReport.adoPost();
        Test.stopTest();
    }
     //传错误数据
    static testMethod void testMethod3() {
        Test.startTest();
        String jsonStr = '"fudgs"';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetGSSInventoryReport.adoPost();
        Test.stopTest();
    }

}