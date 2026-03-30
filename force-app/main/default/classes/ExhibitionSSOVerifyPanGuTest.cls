@isTest
private class ExhibitionSSOVerifyPanGuTest {
    static testMethod void testMethod1() {
        ExhibitionSSOVerifyPanGu.verifyInternalRegistration('limin24');
    }
    static testMethod void testMethod2(){
    	Test.startTest();
    	String json1 = '{"resCode": "SUCCESS","resMess": "SUCCESS","tokenId": "8e37cf631b434911be580ade72ed89b9", "effecTime": "2023-08-30 17:50:53"}';
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        String json = '{"code": "0","timestamp": "1761794259467","data": {    "telephoneNumber": "",    "mail": "taojingpeng.ex@hx-partners.com",    "ou": "%E5%9B%BD%E9%99%85%E8%90%A5%E9%94%80%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88%E9%83%A8",    "otherDepartments": [        "1"    ],    "mobile": "18037506005",    "usertype": "external",    "cn": "%E9%99%B6%E9%9D%96%E6%9C%8B.ex",    "title": "",    "idNumber": "411328199711260679",    "employeeNumber": "",    "o": "%E5%A4%96%E9%83%A8%E4%BA%BA%E5%91%98%5C%E5%A4%96%E5%8D%8F%5C%E9%9B%86%E5%9B%A2%E5%85%AC%E5%8F%B8%5C%E6%95%B0%E8%B4%A8%E4%B8%AD%E5%BF%83%5C%E6%95%B0%E7%A7%91%E5%85%AC%E5%8F%B8%5C%E5%9B%BD%E9%99%85%E8%90%A5%E9%94%80%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88%E9%83%A8",    "uid": "taojingpeng.ex",    "cnen": "taojingpeng.ex",    "sn": "%E9%99%B6"},"msg": "操作成功"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));

       	ExhibitionSSOVerifyPanGu.verifyInternalRegistration('taojingpeng.ex');
       	ExhibitionSSOVerifyPanGu.verifyInternalRegistration('test');
        Test.stopTest();

    }
}