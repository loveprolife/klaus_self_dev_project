@isTest
private class OrderShareBatchTest {
    static testMethod void testMethod1() {
        Mapping__c map1 = new Mapping__c();
    	map1.Name = '1001';
    	map1.Mapping_Code__c = 'TV';
    	Database.insert(map1);
        
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

        Order__c order = new Order__c(
            Customer__c = accId
            
        );
        Database.insert(order);

        Order_Product__c orderProduct = new Order_Product__c(
            Order__c = order.Id,
            SAP_Product_Line__c = map1.Id
        );
        Database.insert(orderProduct);

        Datetime dd = datetime.now();
        OrderShareBatch ss  =new OrderShareBatch(dd.addDays(-1),dd.addDays(1));
		Database.executeBatch(ss);
    }

    static testMethod void testMethod2() {
        Mapping__c map1 = new Mapping__c();
    	map1.Name = '1001';
    	map1.Mapping_Code__c = 'TV';
    	Database.insert(map1);
        
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

        Order__c order = new Order__c(
            Customer__c = accId
            
        );
        Database.insert(order);

        Order_Product__c orderProduct = new Order_Product__c(
            Order__c = order.Id,
            SAP_Product_Line__c = map1.Id
        );
        Database.insert(orderProduct);

        Datetime dd = datetime.now();
        OrderShareBatch ss  =new OrderShareBatch(dd.addDays(-1),dd.addDays(1));
		Database.executeBatch(ss);
        OrderShareBatch ss1  =new OrderShareBatch(new Set<String>{System.UserInfo.getUserId()});
        Database.executeBatch(ss1);
    }
}