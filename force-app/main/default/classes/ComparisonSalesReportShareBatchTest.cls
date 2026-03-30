@isTest
private class ComparisonSalesReportShareBatchTest {
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
        Sales__c sales1 = new Sales__c();
        sales1.Customer__c = accId;
        sales1.Product_Line__c = 'TV';
        sales1.Sales__c = UserInfo.getUserId();
        sales1.IsKeyUser__c = true;
        Database.insert(sales1);

        Comparison_Sales_Report_YoY__c csr1 = new Comparison_Sales_Report_YoY__c();
        csr1.Customer__c = accId;
        csr1.Product_Line_Code__c = 'TV';
        csr1.Year__c = System.now().format('yyyy');
        csr1.Month__c = System.now().month() + '';
        Database.insert(csr1);

        Datetime dd = datetime.now();
        ComparisonSalesReportShareBatch ss  = new ComparisonSalesReportShareBatch(System.now().format('yyyy'),System.now().month() + '');
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

        Comparison_Sales_Report_YoY__c csr1 = new Comparison_Sales_Report_YoY__c();
        csr1.Customer__c = accId;
        csr1.Product_Line_Code__c = 'TV';
        csr1.Year__c = System.now().format('yyyy');
        csr1.Month__c = System.now().month() + '';
        Database.insert(csr1);

        Datetime dd = datetime.now();
        ComparisonSalesReportShareBatch ss  = new ComparisonSalesReportShareBatch(System.now().format('yyyy'),System.now().month() + '');
        Database.executeBatch(ss);


    }
}