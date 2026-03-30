@isTest
private class SC_SalesTargetBranchCompanyUseShareTest {
    static testMethod void testMethod1() {
    	Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        List<User> users = new List<User>();
        User owner = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com',IsActive=true
        );

        User shareUser = new User(
            Alias = 'share', Email='share@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales share', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='share@hisensetest.com',IsActive=true
        );

        users.add(owner);
        users.add(shareUser);
        Database.insert(users);

        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        // Account acc1 = [select Id from Account where External_Key__c='0000504263' limit 1];
        // User owner = [select Id from User where Email='systemadmin@hisensetest.com' limit 1];
        // User shareUser = [select Id from User where Email='share@hisensetest.com' limit 1];

        Sales__c sales1 = new Sales__c();
        sales1.Customer__c = accId;
        sales1.Product_Line__c = 'TV';
        sales1.Sales__c = owner.Id;
        sales1.IsKeyUser__c = true;
        
        Database.insert(sales1);

        Sales_Target_Branch_Company_Use__c stbc = new Sales_Target_Branch_Company_Use__c();
        stbc.Customer_Name__c = accId;
        stbc.Product_Line__c = Label.SACE;
        stbc.Year__c = '2019';
        Database.insert(stbc);

        SC_SalesTargetBranchCompanyUseShareBatch scSTBC = new SC_SalesTargetBranchCompanyUseShareBatch();
        Database.executeBatch(scSTBC,200);
    }
}