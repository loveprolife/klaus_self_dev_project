@isTest
private class CustomerProductLineAddSalesBatchTest {
    static testMethod void testMethod1() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
        ID accId2 = TestDataUtility.createAccount('BatchTest2', '0000504264', '0000504264', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId2;
        customerProductLine.Management_Customer__c = accId2;
        customerProductLine.Sales_member01__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId2;
        cpl.Product_Line__c = 'AC';
        Database.insert(cpl);
        Customer_Product_Line_Add_Sales__c cp2 = new Customer_Product_Line_Add_Sales__c();
        cp2.UserId__c = user1.id;
        cp2.CustomerId__c = accId2;
        cp2.Product_Line__c = 'AC';
        Database.insert(cp2);
        Customer_Product_Line_Add_Sales__c cp3 = new Customer_Product_Line_Add_Sales__c();
        cp3.UserId__c = user1.id;
        cp3.CustomerId__c = accId2;
        cp3.Product_Line__c = 'TV';
        Database.insert(cp3);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        ); 
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);
        Customer_Product_Line_Add_Sales__c cp2 = new Customer_Product_Line_Add_Sales__c();
        cp2.UserId__c = user2.id;
        cp2.CustomerId__c = accId;
        cp2.Product_Line__c = 'TV';
        Database.insert(cp2);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod4() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }

    static testMethod void testMethod5() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod6() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod7() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod8() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod9() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        customerProductLine.Sales_member07__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod10() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        customerProductLine.Sales_member07__c = user1.Id;
        customerProductLine.Sales_member08__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user2.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
   

    static testMethod void testMethod11() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod12() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod13() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod14() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod15() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod16() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod17() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        customerProductLine.Sales_member07__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod18() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        customerProductLine.Sales_member07__c = user1.Id;
        customerProductLine.Sales_member08__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod19() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        customerProductLine.Sales_member07__c = user1.Id;
        customerProductLine.Sales_member08__c = user1.Id;
        customerProductLine.Sales_member09__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
    static testMethod void testMethod20() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Sales_member01__c = user1.Id;
        customerProductLine.Sales_member02__c = user1.Id;
        customerProductLine.Sales_member03__c = user1.Id;
        customerProductLine.Sales_member04__c = user1.Id;
        customerProductLine.Sales_member05__c = user1.Id;
        customerProductLine.Sales_member06__c = user1.Id;
        customerProductLine.Sales_member07__c = user1.Id;
        customerProductLine.Sales_member08__c = user1.Id;
        customerProductLine.Sales_member09__c = user1.Id;
        customerProductLine.Key_Sales__c = user1.Id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        cpl.Flag__c = '1';
        Database.insert(cpl);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }

    static testMethod void testMethod21() {
        Test.startTest();
        ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        ); 
        User user2 = new User(
            Alias = 'admin2', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com'
        );
        User user3 = new User(
            Alias = 'admin3', Email='systemadmin3@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative3', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin3@hisensetest.com'
        );
        User user4 = new User(
            Alias = 'admin4', Email='systemadmin4@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative4', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin4@hisensetest.com'
        );
        User user5 = new User(
            Alias = 'admin5', Email='systemadmin5@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative5', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin5@hisensetest.com'
        );
        User user6 = new User(
            Alias = 'admin6', Email='systemadmin6@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative6', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin6@hisensetest.com'
        );
        User user7 = new User(
            Alias = 'admin7', Email='systemadmin7@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative7', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin7@hisensetest.com'
        );
        User user8 = new User(
            Alias = 'admin8', Email='systemadmin8@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative8', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin8@hisensetest.com'
        );
        User user9 = new User(
            Alias = 'admin9', Email='systemadmin9@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative9', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin9@hisensetest.com'
        );
        User user10 = new User(
            Alias = 'admin10', Email='systemadmin10@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative10', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin10@hisensetest.com'
        );
        User user11 = new User(
            Alias = 'admin11', Email='systemadmin11@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative11', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin11@hisensetest.com'
        );
        Database.insert(user1);
        Database.insert(user2);
        Database.insert(user3);
        Database.insert(user4);
        Database.insert(user5);
        Database.insert(user6);
        Database.insert(user7);
        Database.insert(user8);
        Database.insert(user9);
        Database.insert(user10);
        Database.insert(user11);

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Key_Sales__c = user11.id;
        Database.insert(customerProductLine);

        Customer_Product_Line_Add_Sales__c cpl = new Customer_Product_Line_Add_Sales__c();
        cpl.UserId__c = user1.id;
        cpl.CustomerId__c = accId;
        cpl.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp2 = new Customer_Product_Line_Add_Sales__c();
        cp2.UserId__c = user1.id;
        cp2.CustomerId__c = accId;
        cp2.Product_Line__c = 'TV';
        cp2.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cp3 = new Customer_Product_Line_Add_Sales__c();
        cp3.UserId__c = user2.id;
        cp3.CustomerId__c = accId;
        cp3.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp4 = new Customer_Product_Line_Add_Sales__c();
        cp4.UserId__c = user3.id;
        cp4.CustomerId__c = accId;
        cp4.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp5 = new Customer_Product_Line_Add_Sales__c();
        cp5.UserId__c = user4.id;
        cp5.CustomerId__c = accId;
        cp5.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp6 = new Customer_Product_Line_Add_Sales__c();
        cp6.UserId__c = user5.id;
        cp6.CustomerId__c = accId;
        cp6.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp7 = new Customer_Product_Line_Add_Sales__c();
        cp7.UserId__c = user6.id;
        cp7.CustomerId__c = accId;
        cp7.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp8 = new Customer_Product_Line_Add_Sales__c();
        cp8.UserId__c = user7.id;
        cp8.CustomerId__c = accId;
        cp8.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp9 = new Customer_Product_Line_Add_Sales__c();
        cp9.UserId__c = user8.id;
        cp9.CustomerId__c = accId;
        cp9.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp10 = new Customer_Product_Line_Add_Sales__c();
        cp10.UserId__c = user9.id;
        cp10.CustomerId__c = accId;
        cp10.Product_Line__c = 'TV';
        Customer_Product_Line_Add_Sales__c cp11 = new Customer_Product_Line_Add_Sales__c();
        cp11.UserId__c = user10.id;
        cp11.CustomerId__c = accId;
        cp11.Product_Line__c = 'TV';

        Customer_Product_Line_Add_Sales__c cpp1 = new Customer_Product_Line_Add_Sales__c();
        cpp1.UserId__c = user2.id;
        cpp1.CustomerId__c = accId;
        cpp1.Product_Line__c = 'TV';
        cpp1.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp2 = new Customer_Product_Line_Add_Sales__c();
        cpp2.UserId__c = user3.id;
        cpp2.CustomerId__c = accId;
        cpp2.Product_Line__c = 'TV';
        cpp2.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp3 = new Customer_Product_Line_Add_Sales__c();
        cpp3.UserId__c = user4.id;
        cpp3.CustomerId__c = accId;
        cpp3.Product_Line__c = 'TV';
        cpp3.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp4 = new Customer_Product_Line_Add_Sales__c();
        cpp4.UserId__c = user5.id;
        cpp4.CustomerId__c = accId;
        cpp4.Product_Line__c = 'TV';
        cpp4.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp5 = new Customer_Product_Line_Add_Sales__c();
        cpp5.UserId__c = user6.id;
        cpp5.CustomerId__c = accId;
        cpp5.Product_Line__c = 'TV';
        cpp5.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp6 = new Customer_Product_Line_Add_Sales__c();
        cpp6.UserId__c = user7.id;
        cpp6.CustomerId__c = accId;
        cpp6.Product_Line__c = 'TV';
        cpp6.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp7 = new Customer_Product_Line_Add_Sales__c();
        cpp7.UserId__c = user8.id;
        cpp7.CustomerId__c = accId;
        cpp7.Product_Line__c = 'TV';
        cpp7.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp8 = new Customer_Product_Line_Add_Sales__c();
        cpp8.UserId__c = user9.id;
        cpp8.CustomerId__c = accId;
        cpp8.Product_Line__c = 'TV';
        cpp8.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp9 = new Customer_Product_Line_Add_Sales__c();
        cpp9.UserId__c = user10.id;
        cpp9.CustomerId__c = accId;
        cpp9.Product_Line__c = 'TV';
        cpp9.Flag__c = '1';
        Customer_Product_Line_Add_Sales__c cpp10 = new Customer_Product_Line_Add_Sales__c();
        cpp10.UserId__c = user11.id;
        cpp10.CustomerId__c = accId;
        cpp10.Product_Line__c = 'TV';
        cpp10.Flag__c = '1';

        Database.insert(cpl);
        Database.insert(cp2);
        Database.insert(cp3);
        Database.insert(cp4);
        Database.insert(cp5);
        Database.insert(cp6);
        Database.insert(cp7);
        Database.insert(cp8);
        Database.insert(cp9);
        Database.insert(cp10);
        Database.insert(cp11);

        Database.insert(cpp1);
        Database.insert(cpp2);
        Database.insert(cpp3);
        Database.insert(cpp4);
        Database.insert(cpp5);
        Database.insert(cpp6);
        Database.insert(cpp7);
        Database.insert(cpp8);
        Database.insert(cpp9);
        Database.insert(cpp10);

        Database.executeBatch(new CustomerProductLineAddSalesBatch(),200);
        Test.stopTest();
    }
}