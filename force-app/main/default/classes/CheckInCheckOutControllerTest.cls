/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-10-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class CheckInCheckOutControllerTest {
    static testMethod void testMethod01(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123CheckInCheckOut@noemail.com');
        INSERT user1;
        
        
        String lati2  = '29.4545';
        String lng2 = '106.509';
        String device = 'IPHONE';
        String exceptionMsg = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
            
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;
        system.debug('shopname'+shop.Name);
        system.debug('shopLocation'+shop.Shop_Center_Location__c);
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = shop.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        

        Promoter_Attendance__c pa = new Promoter_Attendance__c();
            
        pa.CheckInStatus__c = '已签到';
        pa.Shop__c = shop.Id;
        //pa.CheckInShop__c = shop.Id;
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = System.today();
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        INSERT pa;

        List<Promoter_Attendance__c> attendanceList = new List<Promoter_Attendance__c>();
        attendanceList.add(pa);
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        INSERT rp; 

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = pa.ExternalId__c;
        ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        INSERT ist;
            
        CheckInCheckOutController.DataSet cd = new CheckInCheckOutController.DataSet();
        cd.Name = 'test';
        cd.Distance = 20;

        List<CheckInCheckOutController.DataSet> dList = new List<CheckInCheckOutController.DataSet>();
        dList.add(cd);

        CheckInCheckOutController.ReturnData  cr = new CheckInCheckOutController.ReturnData();
        cr.isSuccess = true;
        cr.addressStr = 'WITHOUT_ADDRESS';
        cr.failMessage = '123131@deloitte.com';
        cr.thisDay = System.today();
        cr.dataList = dList;
        cr.userType = user1.Name;

        List<String> externalIdList = new List<String>();
        externalIdList.add(pa.ExternalId__c);

        test.startTest();
        system.runAs(user1){
            CheckInCheckOutController.initStoreInfo(lati2,lng2);
            CheckInCheckOutController.initStoreInfoPromote(lati2,lng2,cr,pa);
            CheckInCheckOutController.getStoreInfo(lati2,lng2,shop.Name);
            //CheckInCheckOutController.getShopList(shop.Name);
            CheckInCheckOutController.checkIn(pa.Id,'已签到', shop.Id, ist.Id, cd.Distance, cd.Distance, device, cr.addressStr);
            CheckInCheckOutController.checkOut(pa.Id,'已签到', shop.Id, ist.Id, cd.Distance, cd.Distance, device, cr.addressStr);
            CheckInCheckOutController.getProperErrorMessage(exceptionMsg);
            //CheckInCheckOutController.createInspectionShopTask(shop.Id);
            CheckInCheckOutController.judgeCheckInShop(cd,attendanceList);
            CheckInCheckOutController.getOtherShopTaskList(cr.thisDay,user1.Id,shop.Id);
            CheckInCheckOutController.getInspectionTaskList(externalIdList,user1.Id);
            CheckInCheckOutController.getTaskList(cr.thisDay,user1.Id);
            CheckInCheckOutController.initStoreInfoInspection(lati2,lng2,cr,attendanceList);
            //CheckInCheckOutController.geolocationGetLatLng(cr.addressStr);
            }
        test.stopTest();
	    
    }
    static testMethod void testMethod02(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '巡店员', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123CheckInCheckOut2@noemail.com');
        INSERT user1;
        
            
        Decimal lati  = 11.4545;
        Decimal lng = 120.509;
        String lati2  = '29.4545';
        String lng2 = '106.509';
        String device = 'IPHONE';
        String exceptionMsg = 'ENTITY_IS_LOCKED';

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'test002';
        shop.City__c = '重庆';
        shop.Shop_Center_Location__Latitude__s = 11.4545;
        shop.Shop_Center_Location__Longitude__s = 120.509;
        INSERT shop;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = shop.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        //system.debug('shopList'+shop.Name);
                
        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.ExternalId__c = acc.Id;
        pa.CheckInStatus__c = '已签到';
        pa.Shop__c = shop.Id;
        //pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = System.today();
        INSERT pa;

        List<Promoter_Attendance__c> attendanceList = new List<Promoter_Attendance__c>();
        attendanceList.add(pa);
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        INSERT rp; 

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        INSERT ist;
            
        CheckInCheckOutController.DataSet cd = new CheckInCheckOutController.DataSet();
        cd.Name = 'test';
        cd.Distance = 20;

        List<CheckInCheckOutController.DataSet> dList = new List<CheckInCheckOutController.DataSet>();
        dList.add(cd);

        CheckInCheckOutController.ReturnData  cr = new CheckInCheckOutController.ReturnData();
        cr.isSuccess = true;
        cr.addressStr = 'WITHOUT_ADDRESS';
        cr.failMessage = '123131@deloitte.com';
        cr.thisDay = System.today();
        cr.dataList = dList;
        cr.userType = user1.Name;
        cr.checkOutShop = shop.Id;
        cr.checkInShop = shop.Id;

        List<String> externalIdList = new List<String>();
            externalIdList.add(acc.Id);

        test.startTest();
            system.runAs(user1){
            CheckInCheckOutController.initStoreInfo(lati2,lng2);
            CheckInCheckOutController.initStoreInfoPromote(lati2,lng2,cr,pa);
            CheckInCheckOutController.getStoreInfo(lati2,lng2,shop.Name);
            //CheckInCheckOutController.getShopList(shop.Name);
            CheckInCheckOutController.checkIn(pa.Id,'已签到', shop.Id, ist.Id, cd.Distance, cd.Distance, device, cr.addressStr);
            CheckInCheckOutController.checkOut(pa.Id,'已签到', shop.Id, ist.Id, cd.Distance, cd.Distance, device, cr.addressStr);
            CheckInCheckOutController.getProperErrorMessage(exceptionMsg);
            //CheckInCheckOutController.createInspectionShopTask(shop.Id);
            CheckInCheckOutController.judgeCheckInShop(cd,attendanceList);
            CheckInCheckOutController.getOtherShopTaskList(cr.thisDay,user1.Id,shop.Id);
            CheckInCheckOutController.getInspectionTaskList(externalIdList,user1.Id);
            CheckInCheckOutController.getTaskList(cr.thisDay,user1.Id);
            CheckInCheckOutController.initStoreInfoInspection(lati2,lng2,cr,attendanceList);
            }
        test.stopTest();
	    
    }
  
}