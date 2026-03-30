/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EcssLimitApplicationInfoControllerTest {

    static testMethod void testMethod1() {
        // TO DO: implement unit test
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	Account a = new Account(Name='test',Guarantor_Country_Code__c='CN',City__c='东莞市',Address__c='东莞市南城区元美路丰硕广场1207号',Ecss_Result__c='ECSS Scan Result Passed');
        insert a;
        String reqParam = a.Name + a.Id;
        String json = '{"scanningResults": [{"dataSupplierCode": "DOWJONES","dataSupplierName": "道琼斯","referenceId": "13295974","type": "受限制主体","lawsAndRegulation": "US-OtherOfficialLists, SIE-RelevantRisk","listType": "SIE-RelevantEntityList, US-OOL-TradeRestrictions","name": "test","country": "CN","matchedResult": "中分值"}]}';
        Ecss_Customer_Info__c ec = new Ecss_Customer_Info__c(ecss_result__c='ECSS Scan Result Fails',Req_Name__c= reqParam);        
        //Ecss_Customer_Info__c ec = new Ecss_Customer_Info__c();
        List<Ecss_Customer_Info__c> ecssInfoFromApi = new List<Ecss_Customer_Info__c>();
        ecssInfoFromApi.add(ec);
        insert ec;
        //Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        EcssLimitApplicationInfoController.getEcssInfo(a.Id);
        delete(a);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        // TO DO: implement unit test
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	Account a = new Account(Name='BBCCDD有限公司',Guarantor_Country_Code__c='CN',City__c='东莞市',Address__c='东莞市南城区元美路丰硕广场1207号', Ecss_Result__c='ECSS Scan Result Passed');
        insert a;
        String json = '{"scanningResults": [{"dataSupplierCode": "DOWJONES","dataSupplierName": "道琼斯","referenceId": "13295974","type": "受限制主体","lawsAndRegulation": "US-OtherOfficialLists, SIE-RelevantRisk","listType": "SIE-RelevantEntityList, US-OOL-TradeRestrictions","name": "BBCCDD有限公司","country": "CN","matchedResult": "中分值"}]}';
        Ecss_Customer_Info__c ec = new Ecss_Customer_Info__c(ecss_result__c='ECSS Scan Result Fails',Req_Name__c='BBCCDD有限公司',ExternalID__c='集群科技有限公司');
        insert ec;
        List<Ecss_Customer_Info__c> ecssInfoFromApi = new List<Ecss_Customer_Info__c>();
        ecssInfoFromApi.add(ec);
        ecssInfoFromApi = GetCustomerInfoFromECSS.getCustomerInfoFromEcssApi(a.Name);
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        EcssLimitApplicationInfoController.initData(a.Id);
        delete(ec);
        delete(a);
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        // TO DO: implement unit test
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	Account a = new Account(Name='集群科技有限公司',Guarantor_Country_Code__c='CN',City__c='东莞市',Address__c='东莞市南城区元美路丰硕广场1207号');
        insert a;
        String json = '{"scanningResults": [{"dataSupplierCode": "DOWJONES","dataSupplierName": "道琼斯","referenceId": "13295974","type": "受限制主体","lawsAndRegulation": "US-OtherOfficialLists, SIE-RelevantRisk","listType": "SIE-RelevantEntityList, US-OOL-TradeRestrictions","name": "联众集群（北京）科技有限责任公司","country": "CN","matchedResult": "中分值"}]}';
        Ecss_Customer_Info__c ec = new Ecss_Customer_Info__c(ecss_result__c='ECSS Scan Result Fails',Req_Name__c='集群科技有限公司',ExternalID__c='0010o00002OCcKYAA1CN联众集群（北京）科技有限责任公司');
        insert ec;
        List<Ecss_Customer_Info__c> ecssInfoFromApi = new List<Ecss_Customer_Info__c>();
        ecssInfoFromApi.add(ec);
        ecssInfoFromApi = GetCustomerInfoFromECSS.getCustomerInfoFromEcssApi(a.Name);
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        EcssLimitApplicationInfoController.syncData(a.Id);
        delete(ec);
        delete(a);
        Test.stopTest();
    }


}