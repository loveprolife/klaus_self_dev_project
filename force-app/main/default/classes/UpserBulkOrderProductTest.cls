@isTest
private class UpserBulkOrderProductTest {
    static testMethod void testMethod1() {
    	ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
    	List<Order_Product__c> orderProductList = new List<Order_Product__c>();
    	orderProductList.add(TestDataUtility.createOrderProduct(accId,'0036195576','11'));
        Test.startTest();
        UpserBulkOrderProduct bulkorderProduct = new UpserBulkOrderProduct(orderProductList);
        ID jobID = System.enqueueJob(bulkorderProduct);
        Test.stopTest();
    }

    static testMethod void testMethod2(){
    	List<Order_Product__c> orderProductList = new List<Order_Product__c>();
    	ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
    	orderProductList.add(TestDataUtility.createOrderProduct(accId,'0036195576','11'));
        Test.startTest();
        UpserBulkOrderProductSecond bulkorderProduct = new UpserBulkOrderProductSecond(orderProductList);
        ID jobID = System.enqueueJob(bulkorderProduct);
        Test.stopTest();
    }

    static testMethod void testMethod3(){
    	ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
    	List<Order_Product__c> orderProductList = new List<Order_Product__c>();
    	orderProductList.add(TestDataUtility.createOrderProduct(accId,'0036195576','11'));
    	orderProductList.add(TestDataUtility.createOrderProduct(accId,'0036195577','11'));
        Test.startTest();
        UpserBulkOrderProductSecond bulkorderProduct = new UpserBulkOrderProductSecond(orderProductList);
        ID jobID = System.enqueueJob(bulkorderProduct);
        Test.stopTest();
    }

    static testMethod void testMethod4(){
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Order__c order = new Order__c(
            Customer__c = accId,
            SAP_Order_No__c = '0036195576'
        );
        Database.insert(order);
        List<Order_Product__c> orderProductList = new List<Order_Product__c>();
        for (Integer i=1;i<10002 ;i++ ) {
            Order_Product__c orderProduct = new Order_Product__c(
                Order__c = order.Id,
                External_Key__c = '0036195576'+i
            ); 
            orderProductList.add(orderProduct);
        }
        Test.startTest();
        UpserBulkOrderProduct bulkorderProduct = new UpserBulkOrderProduct(orderProductList);
        ID jobID = System.enqueueJob(bulkorderProduct);
        Test.stopTest();
    }
}