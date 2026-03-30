@isTest
private class SendCustomerVisitToEMPTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"startDate": "2019-01-01","endDate": "2019-01-01"}';
        //reqBody = '{"startDate": "2019-01-01","endDate": "2019-01-01"}';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        SendCustomerVisitToEMP.adoPost() ; 
        Test.stopTest();
    }
    //传空数据
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"startDate": "","endDate": ""}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        SendCustomerVisitToEMP.adoPost();
        Test.stopTest();
    }
     //传错误数据
    static testMethod void testMethod3() {
        Test.startTest();
        String jsonStr = '{"startDate": "www","endDate": "www"}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        SendCustomerVisitToEMP.adoPost();
        Test.stopTest();
    }
}