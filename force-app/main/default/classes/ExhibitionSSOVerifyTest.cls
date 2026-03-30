@isTest
private class ExhibitionSSOVerifyTest {
    static testMethod void testMethod1() {
        ExhibitionSSOVerify.verifyInternalRegistration('limin24');
    }
    static testMethod void testMethod2(){
    	Test.startTest();
    	String json1 = '{"resCode": "SUCCESS","resMess": "SUCCESS","tokenId": "8e37cf631b434911be580ade72ed89b9", "effecTime": "2023-08-30 17:50:53"}';
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        String json = '{"data": [{ "uid": "LiMin24","mail": "limin24@hisense.com", "title": "业务需求分析师", "ou": "数据流程IT与数据管理部", "cn": "李敏","departmentNumber": "jt_xx","displayid": "0","telephoneNumber": "中国(+86)-809398288-99298882","postalAddress": "中国北京北京市东城区山东省青岛市市南区东海西路257号","o": "海信集团集团公司数据流程IT与数据管理部","mobile": "17660901558"}],"code": 0,"message": "成功获取Ldap账号信息","total": null}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));

       	ExhibitionSSOVerify.verifyInternalRegistration('limin24');
       	ExhibitionSSOVerify.verifyInternalRegistration('test');
        Test.stopTest();

    }
}