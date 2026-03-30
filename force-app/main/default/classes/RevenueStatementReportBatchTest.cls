/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
private class RevenueStatementReportBatchTest {
	@testSetup 
    static void setup() {
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        Customer_Product_Line__c customerProductLine1 = new Customer_Product_Line__c();
        customerProductLine1.Product_Line_Name__c = 'WM';
        customerProductLine1.Customer__c = accId;
        customerProductLine1.Management_Customer__c = TestDataUtility.createAccountList(true).get(0).Id;
        customerProductLine1.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine1);

        Credit_Limit_Application__c creditLimitApplication = new Credit_Limit_Application__c();
        creditLimitApplication.Customer__c = accId;
        Sales_Target__c salesTarget = new Sales_Target__c();
        salesTarget.Customer_Name__c = accId;
        salesTarget.Product_Line__c = 'TV';
        salesTarget.Year__c = '2020';
        Database.insert(salesTarget);

        Sales_Target__c salesTarget1 = new Sales_Target__c();
        salesTarget1.Customer_Name__c = accId;
        salesTarget1.Product_Line__c = 'TV';
        salesTarget1.Year__c = '2019';
        Database.insert(salesTarget1);

        Mapping__c mpp = new Mapping__c();
        mpp.Name = '8010';
        mpp.Mapping_Code__c = '8010';
        //mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        Database.insert(mpp);
    }

    static testMethod void testMethod1() {
        RevenueStatementReportBatch rsr = new RevenueStatementReportBatch('2020','1');
        //损益表batch
        Database.executeBatch(rsr,200);
    }
    static testMethod void testMethod2() {
        RevenueStatementReportBatch rsr = new RevenueStatementReportBatch('2020','2');
        //损益表batch
        Database.executeBatch(rsr,200);
    }
}