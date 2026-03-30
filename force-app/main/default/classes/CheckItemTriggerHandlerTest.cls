/**
 * @description       : 
 * @author            : lizunxing
 * @group             : 
 * @last modified on  : 2024-01-30
 * @last modified by  : lizunxing
**/
@isTest
public class CheckItemTriggerHandlerTest {
	@isTest
    static void testMethod1(){
        Test.startTest();
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        String checkItemScopeRecordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'CheckListScope__c' AND DeveloperName = 'South_Africa'].Id;
        User user = new User(
            Alias = 'admin', Email='CustomerOrderInventoryTest@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='Asia/Kuala_Lumpur', IsActive=true,ProfileId = p.Id,
            UserName='CustomerOrderInventoryTest@hisensetest.com',Sales_Region__c = 'Hisense South Africa'
        );
        insert user;

        User user1 = new User(
            Alias = 'admin1', Email='CustomerOrderInventoryTest@hisensetest.com1',
            EmailEncodingKey='UTF-8', LastName='sales representative1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='Asia/Kuala_Lumpur', IsActive=true,ProfileId = p.Id,
            UserName='CustomerOrderInventoryTest@hisensetest.com1',Sales_Region__c = 'Hisense South Africa'
        );
        insert user1;

        Account customerTest = new Account();
        customerTest.Name = '客户';
        Insert customerTest;

        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customerTest.Id;
        store.sales_region__c = 'Hisense South Africa';
        insert store;

        //Promoter_Attendance_Rule__c
        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Principal__c = user.id;
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Promoter_Attendance_Rule__c = par.Id;
        promoterRes.UserEmail__c = '111@hisense.com';
        insert promoterRes;

        Responsible_Person__c promoterRes1 = new Responsible_Person__c();
        promoterRes1.Principal__c = user1.id;
        promoterRes1.Shop_Name__c = store.Id;
        promoterRes1.Promoter_Attendance_Rule__c = par.Id;
        promoterRes1.UserEmail__c = '111@hisense.com1';
        insert promoterRes1;

        CheckItem__c checkItem = new CheckItem__c();
		checkItem.Description__c = 'old';
		checkItem.Active__c = true;
        checkItem.Sales_Region__c = 'Hisense South Africa';
        checkItem.Product_Line__c = 'TV';
        checkItem.Project__c = 'Booth and image';
        checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('South Africa').getRecordTypeId();
        insert checkItem;

        CheckListScope__c checkScope1 = new CheckListScope__c();
        checkScope1.CheckItem__c = checkItem.Id;
        checkScope1.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope1.Sales_Region__c = 'Hisense South Africa';
        checkScope1.Store__c = store.Id;
        insert checkScope1;

        CheckListScope__c checkScope2 = new CheckListScope__c();
        checkScope2.CheckItem__c = checkItem.Id;
        checkScope2.RecordTypeId = checkItemScopeRecordTypeId;
        checkScope2.Sales_Region__c = 'Hisense South Africa';
        checkScope2.Store__c = store.Id;
        checkScope2.Customer__c = customerTest.id;
        insert checkScope2;

        checkItem.Description__c = 'new';
        checkItem.Project__c = 'Material';
        update checkItem;

        update checkScope2;
        delete checkScope2;
        
        Test.stopTest();
    }
}