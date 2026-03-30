@isTest
private class SalesTargetButtonHandlerControllerTest {
    static testMethod void testMethod1() {
    	Sales_Target_Title__c salesTargetTitle = new Sales_Target_Title__c();
    	salesTargetTitle.Name = 'Test';
    	salesTargetTitle.Year__c = '2020';
    	Database.insert(salesTargetTitle);

        List<Account> accList = TestDataUtility.createAccountList(true);

        Sales_Target__c salesTarget = new Sales_Target__c();
        salesTarget.Customer_Name__c = accList[0].Id;
        salesTarget.Product_Line__c = 'TV';
        salesTarget.Sales_Target_Title__c = salesTargetTitle.Id;
        Database.insert(salesTarget);

        Sales_Target_Title__c salesTargetTitle1 = new Sales_Target_Title__c();
        salesTargetTitle1.Name = 'Test1';
        salesTargetTitle1.Year__c = '2021';
        Database.insert(salesTargetTitle1);

        Test.startTest();
        String str = SalesTargetButtonHandlerController.lockRecord(salesTargetTitle.Id);
        String str1 = SalesTargetButtonHandlerController.lockRecord(salesTargetTitle.Id);
        String str2 = SalesTargetButtonHandlerController.unlockRecord(salesTargetTitle.Id);
        String str3 = SalesTargetButtonHandlerController.unlockRecord(salesTargetTitle.Id);
        String str4 = SalesTargetButtonHandlerController.lockRecord(salesTargetTitle1.Id);
        String str5 = SalesTargetButtonHandlerController.unlockRecord(salesTargetTitle1.Id);
        Test.stopTest();
    }
}