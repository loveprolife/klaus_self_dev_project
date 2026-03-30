/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-02-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
private class GetResponsiblePersonFROMSAPTest {

    static testMethod void testHandler() {
        Account acc = new Account();
        acc.Name = 'KS';
        acc.SAP_Customer_Code__c = 'sapcode01';
		INSERT acc;
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        INSERT pro;
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Grid__c = gird1.id;
        shop.Store_No_from_Account__c = '01';
        shop.City__c = '北京市';
        INSERT shop;

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPResponsiblePerson';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '{"FAILREASON":"","ISSUCCESS":"True","itab":[{"KUNWE":"C111","ZPDBM":1,"ZPDDD":1,"ERDAT":20220214,"ERNAM":"YUYUE","ERZET":105359},{"KUNWE":"C820","ZPDBM":2,"ZPDDD":2,"ERDAT":20220214,"ERNAM":"YUYUE","ERZET":105423}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json, 200));
        GetResponsiblePersonFROMSAP.getPersonInfo('8440', '20220101', '20220102');
        Test.stopTest();
    }

    static testMethod void testHandler1() {

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPResponsiblePerson';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json, 400));
        GetResponsiblePersonFROMSAP.getPersonInfo('8440', '20220101', '20220102');
        Test.stopTest();
    }

    static testMethod void testHandler2() {

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPResponsiblePerson';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '{"FAILREASON":"","ISSUCCESS":"False","itab":[]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetResponsiblePersonFROMSAP.getPersonInfo('8440', '20220101', '20220102');
        Test.stopTest();
    }

    static testMethod void testHandler3() {

        Test.startTest();
        List<Interface_Url__c> ifUrlList = new List<Interface_Url__c>();
        Interface_Url__c ifUrl1 = new Interface_Url__c();
        ifUrl1.Name = 'SAPResponsiblePerson';
        ifUrl1.Basic_Url__c = 'https://crmxip.hisense.com:8443/RESTAdapter/';
        ifUrl1.User_Name__c = 'xiaxiaoyang';
        ifUrl1.Password__c = 'hs123456';
        ifUrlList.add(ifUrl1);
        insert ifUrlList;
        String json = '';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetResponsiblePersonFROMSAP.getPersonInfo('8440', '20220101', '20220102');
        Test.stopTest();
    }

    

}