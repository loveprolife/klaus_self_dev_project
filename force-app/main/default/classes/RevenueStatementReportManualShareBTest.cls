@isTest
private class RevenueStatementReportManualShareBTest {
    static testMethod void testMethod1() {
        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
        	Type = 'Management'
        );
        Database.insert(acc1);

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        ID accId = acc1.Id;
        Sales__c sales = new Sales__c();
        sales.Customer__c = accId;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = user1.Id;
        sales.IsKeyUser__c = true;
        Database.insert(sales);

        Revenue_Statement_Report__c rsr = new Revenue_Statement_Report__c();
        rsr.Customer__c = acc1.Id;
        rsr.Product_Line__c = 'TV';
        rsr.Year__c = '2019';
        rsr.Month__c = '1';
        Database.insert(rsr);

       
        RevenueStatementReportManualShareBatch ss  =new RevenueStatementReportManualShareBatch('2019','1');
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

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        ID accId = acc1.Id;
        Sales__c sales = new Sales__c();
        sales.Customer__c = accId;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = user1.Id;
        sales.IsKeyUser__c = false;
        Database.insert(sales);

        Revenue_Statement_Report__c rsr = new Revenue_Statement_Report__c();
        rsr.Customer__c = acc1.Id;
        rsr.Product_Line__c = 'TV';
        rsr.Year__c = '2019';
        rsr.Month__c = '1';
        Database.insert(rsr);

        Datetime dd = datetime.now();
        dd = dd.addMonths(1);
        RevenueStatementReportManualShareBatch ss  =new RevenueStatementReportManualShareBatch('2019','1');
		Database.executeBatch(ss);
    }
}