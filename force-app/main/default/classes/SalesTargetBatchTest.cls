@isTest
private class SalesTargetBatchTest {
    static testMethod void testMethod1() {
    	TestDataUtility.createSalesTargetData('2020', '01');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','2');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod2() {
    	TestDataUtility.createSalesTargetData('2020', '02');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','3');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod3() {
    	TestDataUtility.createSalesTargetData('2020', '03');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','4');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod4() {
    	TestDataUtility.createSalesTargetData('2020', '04');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','5');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod5() {
    	TestDataUtility.createSalesTargetData('2020', '05');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','6');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod6() {
    	TestDataUtility.createSalesTargetData('2020', '06');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','7');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod7() {
    	TestDataUtility.createSalesTargetData('2020', '07');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','8');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod8() {
    	TestDataUtility.createSalesTargetData('2020', '08');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','9');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod9() {
    	TestDataUtility.createSalesTargetData('2020', '09');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','10');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod10() {
    	TestDataUtility.createSalesTargetData('2020', '10');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','11');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod11() {
    	TestDataUtility.createSalesTargetData('2020', '11');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','12');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    }
    static testMethod void testMethod12() {
    	TestDataUtility.createSalesTargetData('2019', '12');
        Test.startTest();
        SalesTargetBatch salesTarget = new SalesTargetBatch('2020','1');
        //SalesTarget 报表
        Database.executeBatch(salesTarget,200);
        Test.stopTest();
    } 
}