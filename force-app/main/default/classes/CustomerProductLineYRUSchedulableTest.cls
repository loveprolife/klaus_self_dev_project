@isTest
private class CustomerProductLineYRUSchedulableTest {
    static testMethod void testMethod1() {
    	List<User> userList = TestDataUtility.createUserList(true);
    	System.runAs(userList[0]){
            User newUser = new User();
            newUser = userList[1];
            newUser.Username = 'sdcostteam001@hisense.com';
            newUser.Id = null;
            newUser.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName =:Label.Role_Name_Sales_CE_Cost LIMIT 1].Id;
            insert newUser;
            System.debug('newUser: ' +newUser);
    	}
        CustomerProductLineYRUpdateSchedulable cpy = new CustomerProductLineYRUpdateSchedulable();
        SchedulableContext sc;
        cpy.execute(sc);
    }
}