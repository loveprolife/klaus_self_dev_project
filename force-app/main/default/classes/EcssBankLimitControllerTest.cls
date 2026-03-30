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
private class EcssBankLimitControllerTest {
    static testMethod void testMethod1() {
        // TO DO: implement unit test
        TestDataUtility.createCustomSettings();

        Test.startTest();
        Account a = new Account(Name='Nedayeh Micron Electronics',Guarantor_Country_Code__c='IR',E_commerce_Customer_Label__c='20');
        insert a;
    	Customer_Banks__c b = new Customer_Banks__c(Bank_Name__c='Siam Commercia',Bank_Country__c='US', Customer__c=a.id,Bank_Account__c='Siam Commercia', Bank_Code__c='Siam Commercia');
        insert b;
        String json = '{"scanningResults": [{"dataSupplierCode": "DOWJONES","dataSupplierName": "道琼斯","referenceId": "13295974","type": "受限制主体","lawsAndRegulation": "US-OtherOfficialLists, SIE-RelevantRisk","listType": "SIE-RelevantEntityList, US-OOL-TradeRestrictions","name": "联众集群（北京）科技有限责任公司","country": "CN","matchedResult": "中分值"}]}';
        Ecss_Customer_Info__c ec = new Ecss_Customer_Info__c (ecss_result__c='ECSS Scan Result Fails',Req_Name__c='Siam Commercia',ExternalID__c='0010o00002OCcKYAA1CN联众集群（北京）科技有限责任公司');
        insert ec;
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        EcssBankLimitApplicationInfoController.initData(b.Id);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        // TO DO: implement unit test
        TestDataUtility.createCustomSettings();

        Test.startTest();
        Account a = new Account(Name='Nedayeh Micron Electronics',Guarantor_Country_Code__c='IR',E_commerce_Customer_Label__c='20');
        insert a;
    	Customer_Banks__c b = new Customer_Banks__c(Bank_Name__c='Siam Commercia',Bank_Country__c='US', Customer__c=a.id,Bank_Account__c='Siam Commercia', Bank_Code__c='Siam Commercia');
        insert b;
        String json = '{"scanningResults": [{"dataSupplierCode": "Hisense","dataSupplierName": "Hisense","referenceId": "EM004","type": "Embargoed Party","lawsAndRegulation": "US-OtherOfficialLists","listType": "US-BIS-Embargo","country": "IR","matchedResult": "High Value"},{"dataSupplierCode": "DOWJONES","dataSupplierName": "DOWJONES","referenceId": "1003608","type": "Restricted Party","lawsAndRegulation": "US-OtherOfficialLists, SIE-RelevantRisk","listType": "SIE-RelevantEntityList, US-OOL-TradeRestrictions","name": "Nedayeh Micron Electronics","country": "IR","city": "Tehran","street": "No. 34 Mansour St.","matchedResult": "High Value"}]}';        
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        EcssBankLimitApplicationInfoController.initData(b.Id);
        Test.stopTest();
    }

    static testMethod void testMethod13() {
        // TO DO: implement unit test
        TestDataUtility.createCustomSettings();

        Test.startTest();
        Account a = new Account(Name='Nedayeh Micron Electronics',Guarantor_Country_Code__c='IR',E_commerce_Customer_Label__c='20');
        insert a;
    	Customer_Banks__c b = new Customer_Banks__c(Bank_Name__c='Siam Commercia',Bank_Country__c='US', Customer__c=a.id,Bank_Account__c='Siam Commercia', Bank_Code__c='Siam Commercia');
        insert b;
        String json = '{"scanningResults": [{"dataSupplierCode": "DOWJONES","dataSupplierName": "道琼斯","referenceId": "13295974","type": "受限制主体","lawsAndRegulation": "US-OtherOfficialLists, SIE-RelevantRisk","listType": "SIE-RelevantEntityList, US-OOL-TradeRestrictions","name": "联众集群（北京）科技有限责任公司","country": "CN","matchedResult": "中分值"}]}';
        Ecss_Customer_Info__c ec = new Ecss_Customer_Info__c (ecss_result__c='ECSS Scan Result Fails',Req_Name__c='Siam Commercia',ExternalID__c='0010o00002OCcKYAA1CN联众集群（北京）科技有限责任公司');
        insert ec;
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        EcssBankLimitApplicationInfoController.syncData(b.Id);
        Test.stopTest();
    }
}