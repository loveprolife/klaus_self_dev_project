@isTest
private class GetDeletedDeliveryOrderFromSAPTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"Token": "Bearer SESSION_ID_REMOVED","DeliveryOrderNumberList": [{"DeliveryOrderNumber": "0087002113","DeliveryOrderItemNumber": "000010"},{"DeliveryOrderNumber": "008704502113","DeliveryOrderItemNumber": ""}]}'; 
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetDeletedDeliveryOrderFromSAP.doPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"Token": "Bearer SESSION_ID_REMOVED","OrderNumberList":null';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        GetDeletedDeliveryOrderFromSAP.doPost();
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
        GetDeletedDeliveryOrderFromSAP.doPost();
        Test.stopTest();
    }
}