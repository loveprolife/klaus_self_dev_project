/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-02-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class GetProductModelFROMSAPTest {

    static testMethod void testHandler() {
        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPProductModel';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '{"FAILREASON":"","ISSUCCESS":"True","itab":[{"ZCUSMODEL":1,"ZCPCC":1,"ZCPDC":1,"ZCPJD":1,"ZCPXL":1,"ZCPFL":1,"MNGYN":111111111111,"ZXSYN":1,"ERDAT":20220214,"ERNAM":20220214,"ERZET":"000000"}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetProductModelFROMSAP.getProduct('20220101', '20220102');
        Test.stopTest();
    }

    static testMethod void testHandler1() {

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPProductModel';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json, 400));
        GetProductModelFROMSAP.getProduct('20220101', '20220102');
        Test.stopTest();
    }

    static testMethod void testHandler2() {

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPProductModel';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '{"FAILREASON":"","ISSUCCESS":"False","itab":[]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetProductModelFROMSAP.getProduct('20220101', '20220102');
        Test.stopTest();
    }

    static testMethod void testHandler3() {

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPProductModel';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetProductModelFROMSAP.getProduct('20220101', '20220102');
        Test.stopTest();
    }
}