@isTest
private class UpdateCustomerProductLineBatchTest {
    static testMethod void testMethod1() {

        Account acc = new Account(
            Name = 'TestAccount 1',
            SAP_Customer_Code__c = '0000504264',
            External_Key__c = '0000504264',
            Sales_Region__c = 'Hisense USA'
        );
        Database.insert(acc);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = acc.Id;
        Database.insert(customerProductLine);
  
        Customer_Information__c cic = new Customer_Information__c(
            Customer_Code__c = '0000504264',
            Product_Line__c = '电视',
            Industry_Position__c = 'TOP客户',
            Industry_Rank__c = '5',
            Cooperation_Level__c = '战略客户',
            Customer_Type__c = '电器连锁',
            Channel_Level__c = '中高端渠道',
            Store_Number__c = '200',
            Market_share_in_customer_s_home_country__c = '35%',
            Annual_sales_scale__c = '500',
            Cooperative_Brand__c = 'Hisense;XXX',
            Actual_Sales_Income_Ratio_21_Year__c = '35%',
            Actual_Sales_Income_Ratio_22_Year__c = '35%'

        );
        Database.insert(cic);

        Test.startTest();
        UpdateCustomerProductLineBatch ucpl = new UpdateCustomerProductLineBatch();
        Database.executeBatch(ucpl,200);
        Test.stopTest();
    }
}