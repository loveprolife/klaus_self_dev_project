@isTest
private class SalesTargetBranchCompanyUseBatchTest {
    static testMethod void testMethod1() {
    	ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        
        Sales__c sales = new Sales__c();
        sales.Customer__c = accId;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = user1.Id;
        sales.IsKeyUser__c = true;
        Database.insert(sales);

        Customer_Product_Line__c cpl = new Customer_Product_Line__c();
        cpl.Management_Customer_Branch_Company__c = accId;
        cpl.Product_Line_Name__c = 'TV';
        cpl.Customer__c = accId;
        cpl.Classification__c = 'Customer of Oversea Company';
        Database.insert(cpl);

        Sales_Target_Branch_Company_Use__c stbc = new Sales_Target_Branch_Company_Use__c();
        stbc.Customer_Name__c = accId;
        stbc.Product_Line__c = Label.SACE;
        stbc.Year__c = '2019';
        Database.insert(stbc);

        SalesTargetBranchCompanyUseShareBatch stbcs = new SalesTargetBranchCompanyUseShareBatch('2019');
        //损益表batch
        Database.executeBatch(stbcs,200);
    }
}