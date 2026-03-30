@isTest
private class ActualAndSamePeriodReportBatchTest {
    static testMethod void testMethod1() {
        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
        	Type = 'Management'
        );
        Database.insert(acc1);
        ID accId = acc1.Id;
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);
        ActualAndSamePeriodReportBatch ss  = new ActualAndSamePeriodReportBatch('2019','1');
		Database.executeBatch(ss);
    }
}