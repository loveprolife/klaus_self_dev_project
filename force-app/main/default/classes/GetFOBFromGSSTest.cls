@isTest
private class GetFOBFromGSSTest {

    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"FOBDataList": [{"BatchNumber":"BKA01","RequestFactoryFinishDate":"2021-10-21","ActualFactoryFinishDate":"2021-10-22","ContainerNumber":111}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetFOBFromGSS.doPost() ; 
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"FOBDataList": [{"BatchNumber":"BKA01","RequestFactoryFinishDate":"0000-00-00","ActualFactoryFinishDate":"","ContainerNumber":111}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetFOBFromGSS.doPost() ; 
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"FOBDataList": [{"BatchNumber":"BKA01","RequestFactoryFinishDate":"2021-10-22","ActualFactoryFinishDate":"2021-10-22","ContainerNumber":aaaa}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetFOBFromGSS.doPost() ; 
        Test.stopTest();
    }

    
    static testMethod void testMethod4() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"FOBDataList": []}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetFOBFromGSS.doPost() ; 
        Test.stopTest();
    }

    static testMethod void testMethod5() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr='{"FOBDataList": [{"BatchNumber":"BKA01","RequestFactoryFinishDate":"2021-10-21","ActualFactoryFinishDate":"2021-10-22","ContainerNumber":111},{"BatchNumber":"BKA01","RequestFactoryFinishDate":"2021-10-21","ActualFactoryFinishDate":"2021-10-22","ContainerNumber":111}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetFOBFromGSS.doPost() ; 
        Test.stopTest();
    }
}