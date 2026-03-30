@isTest
private class GSSInventoryReportShareBatchTest {

    static testMethod void testMethod1() {
        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
        	Type = 'Management'
        );
        Database.insert(acc1);

        GSS_Inventory_Report__c gssIR = new GSS_Inventory_Report__c();
        gssIR.Customer__c = acc1.Id;
        gssIR.ProductLineText__c = 'TV';
        Database.insert(gssIR);

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user2);

        Sales__c sales = new Sales__c();
        sales.Customer__c = acc1.Id;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = user1.Id;
        sales.IsKeyUser__c = true;
        Database.insert(sales);

        Sales__c sales2 = new Sales__c();
        sales2.Customer__c = acc1.Id;
        sales2.Product_Line__c = 'TV';
        sales2.Sales__c = user2.Id;
        sales2.IsKeyUser__c = true;
        Database.insert(sales2);

        GSSInventoryReportShareBatch ss  = new GSSInventoryReportShareBatch();
		Database.executeBatch(ss);

    }

    
    static testMethod void testMethod2() {
        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
        	Type = 'Management'
        );
        Database.insert(acc1);

        GSS_Inventory_Report__c gssIR = new GSS_Inventory_Report__c();
        gssIR.Customer__c = acc1.Id;
        gssIR.ProductLineText__c = 'TV';
        Database.insert(gssIR);

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        GSSInventoryReportShareBatch ss  = new GSSInventoryReportShareBatch();
		Database.executeBatch(ss);

    }

}