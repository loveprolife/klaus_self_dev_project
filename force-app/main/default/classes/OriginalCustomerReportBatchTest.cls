@isTest
private class OriginalCustomerReportBatchTest {
	@testSetup 
    static void setup() {
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Rank__c = 'Strategy Customer';
        customerProductLine.Rank_Of_Last_Year__c = 'Strategy Customer';
        customerProductLine.Rank_Of_The_Year_Before_Last__c = 'Strategy Customer';
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);
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
    }
    static testMethod void testMethod1() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','1');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod2() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','2');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod3() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','3');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod4() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','4');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod5() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','5');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod6() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','6');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod7() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','7');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod8() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','8');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod9() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','9');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod10() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','10');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod11() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','11');
        Database.executeBatch(ocr,200);
    }
    static testMethod void testMethod12() {
        OriginalCustomerReportBatch ocr = new OriginalCustomerReportBatch('2020','12');
        Database.executeBatch(ocr,200);
    }
}