@isTest
private class GetProductStockInfoFromSAPTest {
    static testMethod void testMethod1() {
    	TestDataUtility.createCustomSettings();
    	Test.startTest();
        String jsonStr = '{"SalesOrganization":"False","ProductStock":[{"StorageLocation":"1000","StockinWhse":"1100","EDIVOQty":"1300","DNQty":"1400","AvailableQtyIncEDIVO":"1600","AvailableQtyExEDIVO":"1500","ActualSOQty":"1200"},{"StorageLocation":"2000","StockinWhse":"2100","EDIVOQty":"2300","DNQty":"2400","AvailableQtyIncEDIVO":"2600","AvailableQtyExEDIVO":"2500","ActualSOQty":"2200"}],"isSuccess":"False","failReason":"Test","CustomerModel":"Test Customer Product"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(jsonStr));
        GetProductStockInfoFromSAP.getData('Test Customer Product Model','8200',new List<String>{'1000'});
        Test.stopTest();
    }
    //传错误数据
    static testMethod void testMethod2() {
    	TestDataUtility.createCustomSettings();
    	Test.startTest();
        String jsonStr = '"fudgs"';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(jsonStr));
        GetProductStockInfoFromSAP.getData('Test Customer Product Model','8200',new List<String>{'1000'});
        Test.stopTest();
    }
}