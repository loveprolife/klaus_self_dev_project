@isTest
private class GetCustomerStatusInfoFromSAPTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Account acc = new Account(
        					Name = 'testname',
        					SAP_Customer_Code__c = '0005001234');
        insert acc;
        

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"SAPCustomerCode": "0005001234","CustomerStatus": "FD32","StatusChangingTime": "2014-01-22 10:29:48"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetCustomerStatusInfoFromSAP.doPost() ; 
        Test.stopTest();
    }
    static testMethod void testMethod2() {
        Test.startTest();
        // Account acc = new Account(
        // 					Name = 'testname',
        // 					SAP_Customer_Code__c = '0005001234');
        // insert acc;
        

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"SAPCustomerCode": "0005001234","CustomerStatus": "FD32","StatusChangingTime": "2014-01-22 10:29:48"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetCustomerStatusInfoFromSAP.doPost() ; 
        Test.stopTest();
    }
    static testMethod void testMethod3() {
        Test.startTest();
        

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"xasda"}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetCustomerStatusInfoFromSAP.doPost() ; 
        Test.stopTest();
    }
}