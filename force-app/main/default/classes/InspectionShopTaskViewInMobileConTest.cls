/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 05-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
@isTest
public class InspectionShopTaskViewInMobileConTest {
    
	@isTest
    static void testInspectionShopTaskViewInMobileController(){
        //String profileName = '区域经理';
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TestTom@noemail.com',
        emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        INSERT user1; 
                
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2025';
        ispTest.Inspection_Month__c = '10';
        INSERT ispTest;
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;
        
        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        //ist2.Shop__c = shop1.Id;
        ist2.ExternalId__c = acc.Id;
        ist2.OwnerId = user1.Id;
        //ist2.Status__c = '已到访';
        //ist2.Inspection_Plan__c = ispTest.id;
        //ist2.Inspection_Date__c = date1;
        INSERT ist2;
        
        //String profileName = '巡店员'; 
        //Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        //User user3 = new User(UserRoleId = '00E0l000001D9fLEAS',alias = '区域经理', email='TestTom@noemail.com',
        //emailencodingkey='UTF-8', lastname='TestTom', languagelocalekey='en_US',
        //localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        //timezonesidkey='America/Los_Angeles', username='testTom@noemail.com');
        //INSERT user3;
        
        //UserRole userRole = [SELECT Id,Name FROM UserRole where name = 'CL Floor Worker' Limit 1];
        
        //User user2 = new User(ManagerId = UserInfo.getUserId() , UserRoleId = userRole.Id,alias = '巡店员', email='testJerry@noemail.com',
        //emailencodingkey='UTF-8', lastname='testJerry', languagelocalekey='en_US',
        //localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        //timezonesidkey='America/Los_Angeles', username='testJerry@noemail.com');
        //System.debug(user2);
        //INSERT user2;

        List<String> stringList =new List<String>(); 
        stringList.add(user1.id);
		String ownerIdListJson = JSON.serialize(stringList);
        
        String yearStr = String.valueOf( System.label.All);
        String monthStr = String.valueOf( System.label.All);
        String dayStr = '1';
        
        Test.startTest();
        System.runAs(user1){
        InspectionShopTaskViewInMobileController.setGridOptions(null,null,null,null,null);
        InspectionShopTaskViewInMobileController.getShopOptions(null,null,null,null,null,null);
        InspectionShopTaskViewInMobileController.setGridOptions(shop1.id,shop1.id,shop1.id,shop1.id,shop1.id);
        InspectionShopTaskViewInMobileController.getShopOptions(shop1.id,shop1.id,shop1.id,shop1.id,shop1.id,shop1.id);
        InspectionShopTaskViewInMobileController.initData();
        InspectionShopTaskViewInMobileController.newData(ist,true);
        InspectionShopTaskViewInMobileController.newData(ist,false);
        InspectionShopTaskViewInMobileController.newData(ist2,true);
        InspectionShopTaskViewInMobileController.getData(ownerIdListJson, yearStr, monthStr,dayStr, null, shop1.id, null, false,null,null,null,null,null);
        InspectionShopTaskViewInMobileController.getData(ownerIdListJson, '2024', monthStr,dayStr, null, shop1.id, null, false,null,null,null,null,null);
        InspectionShopTaskViewInMobileController.getData(ownerIdListJson, yearStr, monthStr,dayStr, null, shop1.id, null, false,shop1.id,shop1.id,shop1.id,shop1.id,shop1.id);
    }
        Test.stopTest();
    }

    @isTest
    static void testInspectionShopTaskViewInMobileController2(){

        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.DivisionUnit__c = '国家';
        INSERT gird1;

        Gridding__c gird2 = new Gridding__c();
        gird2.Name = 'test003';
        gird2.DivisionUnit__c = '大区';
        INSERT gird2;

        Gridding__c gird3 = new Gridding__c();
        gird3.Name = 'test004';
        gird3.DivisionUnit__c = '都道府県名';
        INSERT gird3;

        Gridding__c gird4 = new Gridding__c();
        gird4.Name = 'test003';
        gird4.DivisionUnit__c = '市';
        INSERT gird4;

        Gridding__c gird5 = new Gridding__c();
        gird5.Name = 'test003';
        gird5.DivisionUnit__c = '区';
        INSERT gird5;
                
        Shop__c shop1 = new Shop__c();
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        shop1.Sales_Region__c = 'Hisense Canada';
        INSERT shop1;

        
        Test.startTest();
        InspectionShopTaskViewInMobileController.setGridOptions(null,null,null,null,null);
        InspectionShopTaskViewInMobileController.getShopOptions(null,null,null,null,null,null);
        InspectionShopTaskViewInMobileController.setGridOptions(shop1.id,shop1.id,shop1.id,shop1.id,shop1.id);
        InspectionShopTaskViewInMobileController.getShopOptions(shop1.id,shop1.id,shop1.id,shop1.id,shop1.id,shop1.id);
        Test.stopTest();
    }
}