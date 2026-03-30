@isTest
private class SAPCostRevenueDataShareBatchTest {
    static testMethod void testMethod1() {
    	TestDataUtility.createSalesTargetData('2020', '01');
    	String accId = [SELECT Id from Account where SAP_Customer_Code__c = '0000504263' LIMIT 1].Id;
    	Sales__c sales = new Sales__c();
        sales.Customer__c = accId;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = UserInfo.getUserId();
        Database.insert(sales);
        Test.startTest();
        SAPCostRevenueDataShareBatch salesTarget = new SAPCostRevenueDataShareBatch();

        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
}