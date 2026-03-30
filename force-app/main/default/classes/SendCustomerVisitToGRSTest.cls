/**********************************************************************
 * function:传客户拜访信息到GRS Test
 * @author:Yanhao
 * @url: /services/apexrest/rest
 * @data: Customer_Visit__c
 * date:2020-03
 *************************************************************************/
//SendCustomerVisitToGRSTest

@isTest
private class SendCustomerVisitToGRSTest {
    static testMethod void testMethod1() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"START_DATE": "2020-03-16","END_DATE": "2020-03-16","CV_CODE": ""}';
        //reqBody = '{"START_DATE": "2020-03-16","END_DATE": "2020-03-16","CV_CODE": ""} ';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        SendCustomerVisitToEMP.adoPost() ; 
        Test.stopTest();
    }
    //
    static testMethod void testMethod2() {
        Test.startTest();
        String jsonStr = '{"START_DATE": "","END_DATE": "","CV_CODE": "CV202002130038"}';
        RestRequest resq = new RestRequest();
        RestResponse resp = new RestResponse();
        resq.requestBody = Blob.valueOf(jsonStr);
        resq.httpMethod = 'POST';
        RestContext.request = resq;
        RestContext.response = resp;
        SendCustomerVisitToEMP.adoPost();
        Test.stopTest();
    }
     //
    static testMethod void testMethod3() {
        Test.startTest();
        String jsonStr = '{"START_DATE": "","END_DATE": "","CV_CODE": ""}';
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