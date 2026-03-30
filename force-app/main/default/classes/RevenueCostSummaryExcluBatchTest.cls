@isTest
private class RevenueCostSummaryExcluBatchTest {
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

        Mapping__c mpp = new Mapping__c();
        mpp.Name = '8010';
        mpp.Mapping_Code__c = '8010';
        mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        Database.insert(mpp);
        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp1);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        SAP_Cost_Revenue_Data__c costRevenueData = new SAP_Cost_Revenue_Data__c();
        costRevenueData.Year__c = '2019';
        costRevenueData.Month__c = '01';
        costRevenueData.CurrencyIsoCode = 'MYR';
        costRevenueData.Company_Code__c = mpp.Id;
        costRevenueData.Business_Scope__c = mpp1.Id;
        costRevenueData.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData.Customer__c = accId;
        Database.insert(costRevenueData);

        SAP_Cost_Revenue_Data__c costRevenueData1 = new SAP_Cost_Revenue_Data__c();
        costRevenueData1.Year__c = '2018';
        costRevenueData1.Month__c = '02';
        costRevenueData1.CurrencyIsoCode = 'MYR';
        costRevenueData1.Company_Code__c = mpp.Id;
        costRevenueData1.Business_Scope__c = mpp1.Id;
        costRevenueData1.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData1.Customer__c = accId;
        Database.insert(costRevenueData1);

        Actual_And_Same_Period_Report__c apr = new Actual_And_Same_Period_Report__c();
        apr.Customer__c = acc1.Id;
        apr.Customer_Product_Line__c = customerProductLine.Id;
        apr.Year__c = '2019';
        apr.Month__c = '02';
        apr.External_ID__c = '201902' + acc1.Id  + 'TV';
        Database.insert(apr);

        Actual_And_Same_Period_Report__c apr1 = new Actual_And_Same_Period_Report__c();
        apr1.Customer__c = acc1.Id;
        apr1.Customer_Product_Line__c = customerProductLine.Id;
        apr1.Year__c = '2019';
        apr1.Month__c = '01';
        apr1.External_ID__c = '201901' + acc1.Id  + 'TV';
        Database.insert(apr1);
        Test.startTest();

        RevenueCostSummaryExcluBatch rcs = new RevenueCostSummaryExcluBatch('2019', '2', 'Hisense USA');
        Database.executeBatch(rcs,200);
        Test.stopTest();
    }
}