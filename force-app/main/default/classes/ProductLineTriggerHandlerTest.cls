@isTest
private class ProductLineTriggerHandlerTest {
    static testMethod void testMethod1() {
        List<User> userList = TestDataUtility.createUserList(true);
        TestDataUtility.createCustomSettings();
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        customerProductLine.Key_Sales__c = userList[0].Id;
        customerProductLine.Expected_Development_Date__c = Date.today().addDays(3);
        insert customerProductLine;
        customerProductLine.Rank__c = 'Eliminated Customer';
        customerProductLine.Key_Sales__c = System.UserInfo.getUserId();
        customerProductLine.Expected_Development_Date__c = Date.today().addDays(5);
        update customerProductLine;
        delete customerProductLine;
    }
}