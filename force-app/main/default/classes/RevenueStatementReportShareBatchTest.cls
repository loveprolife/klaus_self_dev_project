@isTest
private class RevenueStatementReportShareBatchTest {
    @testSetup 
    static void setup() {
        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
        	Type = 'Management'
        );
        Database.insert(acc1);
        ID accId1 = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
        ID accId = acc1.Id;
        Sales__c sales = new Sales__c();
        sales.Customer__c = accId;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = UserInfo.getUserId();
        Database.insert(sales);
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Rank__c = 'Strategy Customer';
        customerProductLine.Rank_Of_Last_Year__c = 'Strategy Customer';
        customerProductLine.Rank_Of_The_Year_Before_Last__c = 'Strategy Customer';
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);
        Customer_Product_Line__c customerProductLine1 = new Customer_Product_Line__c();
        customerProductLine1.Product_Line_Name__c = 'TV';
        customerProductLine1.Customer__c = accId1;
        customerProductLine1.Management_Customer__c = accId1;
        customerProductLine1.Rank__c = 'Strategy Customer';
        customerProductLine1.Rank_Of_Last_Year__c = 'Strategy Customer';
        customerProductLine1.Rank_Of_The_Year_Before_Last__c = 'Strategy Customer';
        customerProductLine1.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine1);
        Revenue_Statement_Report__c rsr = new Revenue_Statement_Report__c();
        rsr.Customer__c = accId;
        rsr.Product_Line__c = 'TV';
        rsr.Year__c = '2020';
        rsr.Month__c = '1';
        Database.insert(rsr);
    }
    static testMethod void testMethod1() {
        RevenueStatementReportShareBatch cvrr = new RevenueStatementReportShareBatch();
        Database.executeBatch(cvrr,200);
    }
}