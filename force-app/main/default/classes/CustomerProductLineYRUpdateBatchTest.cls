@isTest
private class CustomerProductLineYRUpdateBatchTest {
    static testMethod void testMethod1() {
    	Test.startTest();
        List<Account> accList = TestDataUtility.createAccountList(true);
        Customer_Product_Line__c cpl = new Customer_Product_Line__c();
        cpl.Customer__c = accList[0].Id;
        cpl.Rank_Of_The_Year_Before_Last__c = 'Normal Customer';
        cpl.Rank_Of_Last_Year__c = 'Quality Customer';
        cpl.Rank__c = 'Strategy Customer';
        cpl.Classification__c = 'Customer of Oversea Company';
        insert cpl;
        Database.executeBatch(new CustomerProductLineYearRankUpdateBatch(),200);
        Test.stopTest();
    }
}