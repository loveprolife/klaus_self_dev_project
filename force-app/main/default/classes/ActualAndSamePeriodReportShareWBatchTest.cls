@isTest
private class ActualAndSamePeriodReportShareWBatchTest {
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

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        Actual_And_Same_Period_Report__c apr = new Actual_And_Same_Period_Report__c();
        apr.Customer__c = acc1.Id;
        apr.Customer_Product_Line__c = customerProductLine.Id;
        apr.Year__c = '2019';
        apr.Month__c = '01';
        Database.insert(apr);

        Datetime dd = datetime.now();
        dd = dd.addMonths(1);
        ActualAndSamePeriodReportShareBatch ss  = new ActualAndSamePeriodReportShareBatch('2019','1');
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

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        Actual_And_Same_Period_Report__c apr = new Actual_And_Same_Period_Report__c();
        apr.Customer__c = acc1.Id;
        apr.Customer_Product_Line__c = customerProductLine.Id;
        apr.Year__c = '2019';
        apr.Month__c = '01';
        Database.insert(apr);

        Datetime dd = datetime.now();
        dd = dd.addMonths(1);
        ActualAndSamePeriodReportShareWBatch ss  = new ActualAndSamePeriodReportShareWBatch('2019','1');
        Database.executeBatch(ss);
    }
}