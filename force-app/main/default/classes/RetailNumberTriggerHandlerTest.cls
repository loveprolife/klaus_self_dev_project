@isTest
public class RetailNumberTriggerHandlerTest {
    //static  String outRecordId = Schema.SobjectType.StockItem__c.getRecordTypeInfosByDeveloperName().get('Out').getRecordTypeId();
     @isTest
    static void TestRetailNumberTrigger(){
       String profileName = 'Chile Promoter'; 
       Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
       User user1 = new User(alias = '巡店员', email='testRetail123@noemail.com',
       emailencodingkey='UTF-8', lastname='testRetail123', languagelocalekey='en_US',
       localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
       timezonesidkey='America/Los_Angeles', username='testRetail123@noemail.com');
       INSERT user1;
         
       //List<UserRole> roleId = [SELECT id from UserRole where name='SouthAfrica Regional Manager GP1']; 
       //Id roId = roleId[0].Id;
       //String profileName2 = 'South Africa Promoter'; 
       //Id profileIdSA = [SELECT Id FROM profile WHERE Name = :profileName2][0].Id;
       //User user2 = new User(alias = '促销员', email='test12343y493@noemail.com',Country__c = 'South Africa',
       //emailencodingkey='UTF-8', lastname='Testing12334873', languagelocalekey='en_US',UserRoleId = roId,
       //localesidkey='en_US', profileid = profileIdSA, country='United States',IsActive =true,Sales_Region__c = 'Hisense South Africa',
       //timezonesidkey='America/Los_Angeles', username='test123034343@noemail.com');
       //INSERT user2;
        
       Id regionalProduct = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
       Product__c productTest = new Product__c();
       productTest.RecordTypeId = regionalProduct;
       productTest.Name = 'NTC-22E';
       productTest.CurrencyIsoCode = 'USD';
       productTest.Product_External_Id__c = 'NTC-22E-jp';
       Insert productTest;
       
       Product__c productTest2 = new Product__c();
       productTest2.RecordTypeId = regionalProduct;
       productTest2.Name = 'NEW-22E';
       productTest2.CurrencyIsoCode = 'USD';
       productTest2.Product_External_Id__c = 'NEW-23-CN';
       Insert productTest2;
        
       Account customerTest = new Account();
       customerTest.Name = '测试客户1';
       Insert customerTest;
        
       Shop__c shopTest = new Shop__c();
       shopTest.Name = '测试门店1';
       shopTest.City__c = '重庆';
       shopTest.Account__c = customerTest.id;
       shopTest.Shop_Level__c = 'A';
       shopTest.Responsible_Person__c = user1.id;
       shopTest.sales_region__c = 'Hisense South Africa';
       Insert shopTest;
       
       Inventory__c inventoryTestStore = new Inventory__c();
       Id idStore = Schema.SObjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('StoreStock').getRecordTypeId();
       inventoryTestStore.RecordTypeId = idStore;
       //inventoryTestStore.Name = '测试库存1';
       inventoryTestStore.Product__c = productTest.id;
       inventoryTestStore.Shop__c = shopTest.Id;
       inventoryTestStore.Inventory_Number__c = 1;
       inventoryTestStore.Customer__c = customerTest.id;
       Insert inventoryTestStore;
       
       Inventory__c inventoryTestCustomer = new Inventory__c();
       Id idCustomer = Schema.SObjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();
       inventoryTestCustomer.RecordTypeId = idCustomer;
       //inventoryTestCustomer.Name = '测试库存2';
       inventoryTestCustomer.Product__c = productTest.id;
       inventoryTestCustomer.Shop__c = shopTest.Id;
       inventoryTestCustomer.Customer__c = customerTest.id;
       inventoryTestCustomer.Inventory_Number__c = 1;
       inventoryTestCustomer.Customer__c = customerTest.id;
       Insert inventoryTestCustomer;
        
       Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
       pdr.Shop__c = shopTest.id;
       pdr.Report_Date__c = Date.valueOf('2023-12-13');
       pdr.OwnerId = user1.id;
       insert pdr; 
       pdr.Status__c = 'Submitted';
       pdr.SARegionalManager__c = user1.id;
       update pdr; 
       Promoter_Daily_Report__c pdr1 = new Promoter_Daily_Report__c();
       pdr1.Shop__c = shopTest.id;
       pdr1.Report_Date__c = Date.valueOf('2024-12-13');
       pdr1.OwnerId = user1.id;
       insert pdr1; 
	   System.debug('日期——————————————————————————————————'+pdr.Report_Date__c);
        
        
       Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
       //testResponsiblePerson.RecordTypeId = Schema.SObjectType.Responsible_Person__c.getRecordTypeInfosByName().get('Store').getRecordTypeId();
       testResponsiblePerson.Shop_Name__c = shopTest.id;
       testResponsiblePerson.RecordType__c = '促销员';
       testResponsiblePerson.Principal__c = user1.id;
       Insert testResponsiblePerson;
        
       SalesGoal__c testSalesGoal = new SalesGoal__c();
       testSalesGoal.Year__c = '2023';
       testSalesGoal.Month__c = '12';
       testSalesGoal.Day__c = 31;
       testSalesGoal.StartTime__c = Datetime.newInstance(2023,1,13,10,12,0);
       testSalesGoal.EndingTime__c = Datetime.newInstance(2023,12,13,10,12,0);
       testSalesGoal.Product__c = productTest.id;
       testSalesGoal.Promoter__c = user1.id;
       testSalesGoal.Store__c = shopTest.id;
       testSalesGoal.RecordTypeId = Schema.SObjectType.SalesGoal__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
       testSalesGoal.ResponsiblePerson__c = testResponsiblePerson.id;
       testSalesGoal.CompletedSales__c = 1999;
       testSalesGoal.IsActive__c = true;
       testSalesGoal.Amounts__c = 20;
       Insert testSalesGoal;
        
       SalesGoal__c testSalesGoal2 = new SalesGoal__c();
       testSalesGoal2.Year__c = '2023';
       testSalesGoal2.Month__c = '12';
       testSalesGoal2.Day__c = 30;
       testSalesGoal2.TargetDay__c =DATE.valueOf('2023-09-01');
       testSalesGoal2.StartTime__c = Datetime.newInstance(2023,2,13,10,12,0);
       testSalesGoal2.EndingTime__c = Datetime.newInstance(2023,12,13,10,12,0);
       testSalesGoal2.Product__c = productTest.id;
       testSalesGoal2.Promoter__c = user1.id;
       testSalesGoal2.Store__c = shopTest.id;
       testSalesGoal2.RecordTypeId = Schema.SObjectType.SalesGoal__c.getRecordTypeInfosByName().get('Day').getRecordTypeId();
       testSalesGoal2.ResponsiblePerson__c = testResponsiblePerson.id;
       testSalesGoal2.CompletedSales__c = 1999;
       testSalesGoal2.IsActive__c = true;
       testSalesGoal2.Amounts__c = 20;
       Insert testSalesGoal2;
        
       Retail_Number__c rN = new Retail_Number__c();
       rN.Number__c = 1;
       rN.Price__c = 199;
       rN.PromoterDailyReport__c = pdr.Id;
       rN.Product__c = productTest.Id;
       rN.Shop__c = shopTest.id;
       rN.TotalPrice__c = 199;
       rN.SalesGoal__c = testSalesGoal.id;

       Retail_Number__c rN1 = new Retail_Number__c();
       rN1.Number__c = 1;
       rN1.Price__c = 199;
       rN1.PromoterDailyReport__c = pdr1.Id;
       rN1.Product__c = productTest.Id;
       rN1.Shop__c = shopTest.id;
       rN1.TotalPrice__c = 199;
       rN1.SalesGoal__c = testSalesGoal.id;
       rN1.Status__c = 'Submitted';
        
       Test.startTest();
       DataBase.insert(rN);
       DataBase.insert(rN1);
       Retail_Number__c updateRetailNumber = [Select id,Number__c,Price__c,SalesGoal__c,TotalPrice__c,Product__c,Shop__c,PromoterDailyReport__c From Retail_Number__c where PromoterDailyReport__c = :pdr.id];
       //System.debug('5555555555555555555555555555555555555555555555555555'+updateRetailNumber);
       updateRetailNumber.Number__c = 3;
       DataBase.Update(updateRetailNumber);
       updateRetailNumber.Product__c = productTest2.id;
       updateRetailNumber.SalesGoal__c = testSalesGoal2.id;
       DataBase.Update(updateRetailNumber);
       //rN.Number__c = 3;
       //update updateRetailNumber;

       updateRetailNumber.Status__c = 'Submitted';
       update updateRetailNumber;

       updateRetailNumber.Number__c = 5;
       updateRetailNumber.Price__c = 200;
       update updateRetailNumber;
       
       delete updateRetailNumber;
       Test.stopTest();
    }
    
}