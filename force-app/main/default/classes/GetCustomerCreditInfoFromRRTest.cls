@isTest
private class GetCustomerCreditInfoFromRRTest {
    static testMethod void testMethod1() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
        Test.startTest();
        Account acc = new Account(
                            Name = 'testname',
                            Sales_Region__c = 'Hisense USA',
                            SAP_Customer_Code__c ='34256456',
                            RR_China_Credit__c = '2306');
        insert acc;
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Customer__c = acc.Id,
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c = 'testtest');
        insert newCredit;
        Credit_Limit_Application__c getrecordinfo = [SELECT Name,Payment_Method__c FROM Credit_Limit_Application__c WHERE id =: newCredit.Id Limit 1];


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"SFCode": "'+getrecordinfo.Name+'","CustomerNameFromRR":"test by johnson","ChinaCreditInsuranceBuyerCode": "2306","EffectiveStartTime": "2019-04-08 15:01:43.757","EffectiveEndTime": "2019-04-08 16:01:43.757","RRApprovalStatus": "Insurance Company Approved","RRRejectionPerson": "\u5f20\u6587\u8273","RRRejectionTime": "2019-04-09 15:01:43.757","RRApprovalInformation": "","Creditrating": "xxxxxxxxxx","Finalavailability": "5.000","RecommendedBillingPeriod": "2.00","AttachmentListFromRR":[{"AttachmentLink":"","AttachmentName":""}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetCustomerCreditInfoFromRR.doPost() ; 
        Test.stopTest();
    }
    static testMethod void testMethod2() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
        Test.startTest();
        Account acc = new Account(
                            Name = 'testname');
        insert acc;
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Customer__c = acc.Id,
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c = 'testtest');
        insert newCredit;
        Credit_Limit_Application__c getrecordinfo = [SELECT Name,Payment_Method__c FROM Credit_Limit_Application__c WHERE id =: newCredit.Id Limit 1];


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{"SFCode": "'+getrecordinfo.Name+'","ChinaCreditInsuranceBuyerCode": "","EffectiveStartTime": "","EffectiveEndTime": "","RRApprovalStatus": "Risk Post Rejected","RRRejectionPerson": "\u5f20\u6587\u8273","RRRejectionTime": "2019-04-09 15:01:43.757","RRApprovalInformation": "","Creditrating": "","Finalavailability": "","RecommendedBillingPeriod": "","AttachmentListFromRR":[{"AttachmentLink":"","AttachmentName":""}]}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);
        delete getrecordinfo;

        GetCustomerCreditInfoFromRR.doPost() ; 
        Test.stopTest();
    }
    static testMethod void testMethod3() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
        Test.startTest();
        Account acc = new Account(
                            Name = 'testname');
        insert acc;
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Customer__c = acc.Id,
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c = 'testtest');
        insert newCredit;
        Credit_Limit_Application__c getrecordinfo = [SELECT Name,Payment_Method__c FROM Credit_Limit_Application__c WHERE id =: newCredit.Id Limit 1];


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String jsonStr = '{}';
     
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(jsonStr);

        GetCustomerCreditInfoFromRR.doPost() ; 
        Test.stopTest();
    }
}