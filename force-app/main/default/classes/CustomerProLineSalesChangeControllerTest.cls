@isTest
private class CustomerProLineSalesChangeControllerTest {
    
    static testMethod void testMethod1() {
        Test.startTest();

        List<User> userList = TestDataUtility.createUserList(true);
        System.runAs(userList[0]){
            User newUser = new User();
            newUser = userList[1];
            newUser.Username = 'sdcostteam001@hisense.com';
            newUser.Id = null;
            newUser.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName =:Label.Role_Name_Sales_CE_Cost LIMIT 1].Id;
            insert newUser;

            User newUser2 = new User();
            newUser2.Alias = 'test';
            newUser2.Email = 'test@hisensetest.com';
            newUser2.EmailEncodingKey = 'UTF-8';
            newUser2.Username = 'sdcostteam002@hisense.com';
            newUser2.LastName='sales representative'; 
            newUser2.LanguageLocaleKey='en_US';
            newUser2.LocaleSidKey='en_US';
            newUser2.ProfileId = newUser.ProfileId; 
            newUser2.TimeZoneSidKey='Asia/Kuala_Lumpur';
            newUser2.Id = null;
            newUser2.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName =:Label.Role_Name_Sales_CE_Cost LIMIT 1].Id;
            insert newUser2;
    
            List<Account> accList = TestDataUtility.createAccountList(true);
            Customer_Product_Line__c cpl = new Customer_Product_Line__c();
            cpl.Customer__c = accList[0].Id;
            cpl.Rank_Of_The_Year_Before_Last__c = 'Normal Customer';
            cpl.Rank_Of_Last_Year__c = 'Quality Customer';
            cpl.Rank__c = 'Strategy Customer';
            cpl.Classification__c = 'Customer of Oversea Company';
            cpl.Sales_member01__c = newUser.Id;
            insert cpl;
            CustomerProLineSalesChangeController.changeTwoSales('', '');
            CustomerProLineSalesChangeController.changeTwoSales(newUser2.Id, newUser.Id);
            String s1 = newUser.Id;
            String s2 = newUser2.Id;
            CustomerProLineSalesChangeController.changeTwoSales(s1.substring(0,15), s2.substring(0,15));
    	}
        Test.stopTest();
    }
}