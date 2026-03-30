@isTest
public class CheckListControllerTest {
	// @IsTest
    // static void testCheckListController(){
    //     Test.startTest();
        
    //     NewTestDataUtility.makeCheckListInfo();

    //     User floorwalker = NewTestDataUtility.floorwalker;
    //     Shop__c store = NewTestDataUtility.store;
    //     Account customer = NewTestDataUtility.customer;
    //     CheckListScope__c checkScope = NewTestDataUtility.checkScope;

    //     CheckListController.getCheckList(store.Id, floorwalker.Id);
    //     CheckListController.getStoreCheckList(store.Id);

    //     checkScope.Customer__c = customer.Id;
    //     update checkScope;

    //     CheckListController.getCheckList(store.Id, floorwalker.Id);
    //     CheckListController.testClassMethod();

    //     Test.stopTest();
    // }

    @IsTest
    static void testCheckListController2(){
        
        Test.startTest();
        String monthRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Month'].Id;
        String dayRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'SalesGoal__c' AND DeveloperName = 'Day'].Id;
        String checkItemRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckItem__c' AND DeveloperName = 'South_Africa'].Id;
        String checkItemScopeRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckListScope__c' AND DeveloperName = 'South_Africa'].Id;

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        customer.Sales_Region__c = 'Hisense South Africa';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense South Africa';
        insert store;
        
        User floorwalker = new User();
        floorwalker.Username = 'testUser12138@test004.com';
        floorwalker.lastname = 'testUser12138';
        floorwalker.alias = 'test';
        floorwalker.email ='testUser@test.com';
        floorwalker.emailencodingkey = 'UTF-8';
        floorwalker.languagelocalekey = 'zh_CN';
        floorwalker.LocaleSidKey = 'zh_CN';
        floorwalker.IsActive = true;
        floorwalker.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%South Africa Floorwalker%'][0].Id;
        floorwalker.timezonesidkey ='Asia/Shanghai';
        floorwalker.Country = 'ZA';
        floorwalker.Sales_Region__c = 'Hisense South Africa';
        insert floorwalker;
        
        Responsible_Person__c resPerson = new Responsible_Person__c();
        resPerson.Shop_Name__c = store.Id;
        resPerson.Principal__c = floorwalker.Id;
        resPerson.RecordType__c = '巡店员';
        insert resPerson;

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.RecordTypeId = checkItemRecordTypeId;
        checkItem.Sales_Region__c = 'Hisense South Africa';
        checkItem.Description__c = 'test';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Personnel';
        insert checkItem;

        CheckListScope__c checkScope = new CheckListScope__c();
        checkScope.CheckItem__c = checkItem.Id;
        checkScope.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope.Sales_Region__c = 'Hisense South Africa';
        checkScope.Store__c = store.Id;
        checkScope.Role__c = 'Floorwalker';
        insert checkScope;

        CheckListController.getCheckList(store.Id, floorwalker.Id);
        CheckListController.getStoreCheckList(store.Id);

        checkScope.Customer__c = customer.Id;
        update checkScope;

        CheckListController.getCheckList(store.Id, floorwalker.Id);

        Test.stopTest();
        
    }
}