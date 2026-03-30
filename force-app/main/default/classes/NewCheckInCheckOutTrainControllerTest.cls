@isTest
public with sharing class NewCheckInCheckOutTrainControllerTest{
    static testMethod void testMethod1(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='NewCheckInCheckOutTrain@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing1010101', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='NewCheckInCheckOutTrain@noemail.com');
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
        pa.OwnerId = user1.id;
        pa.CheckInStatus__c = '已签到';
        pa.Shop__c = shop.Id;
        //pa.CheckInShop__c = shop.Id;
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = System.today();
        pa.CheckInAddress__c = 'test address';
        pa.SignInTime__c = Time.newInstance(9,30,00,00);
        pa.Check_in_Type__c = 'Onsite';
        pa.Check_in_Status__c = 'Late Check in';
        pa.CheckOutShop__c = shop.Id;
        pa.CheckOutAddress__c = 'test';
        pa.SignOutTime__c = Time.newInstance(18,30,00,00);
        pa.Check_out_Type__c = 'Onsite';
        pa.Check_out_Status__c = 'Check out';
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        INSERT pa;
        System.debug('<------------------>'+pa.OwnerId + '_' + System.today());

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(9, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        insert testPAR;
        
        List<String> attendanceList = new List<String>();
        attendanceList.add(pa.Id);
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Promoter_Attendance_Rule__c = testPAR.id;
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
        Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
        pai.Promoter_Attendance__c = pa.Id;
        pai.Shop__c = shop.Id;
        pai.Address__c = 'WITHOUT_ADDRESS';
        pai.CheckIn_Date__c =  System.today();
        pai.CheckIn_Time__c = Time.newInstance(9,30,00,00);
        insert pai;
        
        //Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        //testPAR.Shop_Name__c = shop.id;
        
            
        NewCheckInCheckOutTrainController.DataSet cd = new NewCheckInCheckOutTrainController.DataSet();
        cd.Name = 'test';
        cd.Distance = 20;

        List<NewCheckInCheckOutTrainController.DataSet> dList = new List<NewCheckInCheckOutTrainController.DataSet>();
        dList.add(cd);

        NewCheckInCheckOutTrainController.ReturnData  cr = new NewCheckInCheckOutTrainController.ReturnData();
        cr.isSuccess = true;
        cr.addressStr = 'WITHOUT_ADDRESS';
        cr.failMessage = '123131@deloitte.com';
        cr.thisDay = System.today();
        cr.dataList = dList;
        cr.userType = user1.Name;

        List<String> externalIdList = new List<String>();
        externalIdList.add(pa.ExternalId__c);
        String em1 = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        String em2 = 'ENTITY_IS_LOCKED';
        String em3 = 'FIELD_INTEGRITY_EXCEPTION';
        String em4 = 'FIELD_FILTER_VALIDATION_EXCEPTION';
        String em5 = 'DUPLICATE_VALUE';
        String em6 = 'DUPLICATES_DETECTED';
            
        NewCheckInCheckOutTrainController.DataSet testSet1 = new NewCheckInCheckOutTrainController.DataSet();
        testSet1.Distance = 155.5;

        NewCheckInCheckOutTrainController.DataSet testSet2 = new NewCheckInCheckOutTrainController.DataSet();
        testSet1.Distance = 150.5;

        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
        );
        insert contentVersion;  

        test.startTest();
        // system.runAs(user1){
            NewCheckInCheckOutTrainController.initStoreInfo(lati2,lng2,'test');
            //NewCheckInCheckOutTrainController.initStoreInfoPromote(lati2,lng2,cr,pa);
            NewCheckInCheckOutTrainController.checkIn(pa.CheckInStatus__c,shop.Id,lati,lng,device,cr.addressStr,'test001','test','test','1','2','3');
            NewCheckInCheckOutTrainController.checkIn(pa.CheckInStatus__c,shop.Id,lati,lng,device,cr.addressStr,'test001','test','test','1','2','3');
            NewCheckInCheckOutTrainController.checkOut(pa.CheckInStatus__c,shop.Id,lati,lng,device,cr.addressStr,'test001','test','test','',acc.Id,'1','2','3','4','5','6','7','8','1','2','3');
            NewCheckInCheckOutTrainController.checkStoreAttendance(shop.Id);
            NewCheckInCheckOutTrainController.getAttendanceLabel(attendanceList);
            NewCheckInCheckOutTrainController.getExistAttendance(pa.ExternalId__c);
            NewCheckInCheckOutTrainController.createUploadFile(pa.id,'test123123test123123test123123test123123test123123test123123');
            //NewCheckInCheckOutTrainController.geolocationGetAddress(lati2,lng2);
            NewCheckInCheckOutTrainController.getProperErrorMessage(em1);
            NewCheckInCheckOutTrainController.getProperErrorMessage(em2);
            NewCheckInCheckOutTrainController.getProperErrorMessage(em3);
            NewCheckInCheckOutTrainController.getProperErrorMessage(em4);
            NewCheckInCheckOutTrainController.getProperErrorMessage(em5);
            NewCheckInCheckOutTrainController.getProperErrorMessage(em6);

            NewCheckInCheckOutTrainController.getBase64Stream(contentVersion.Id);
        // }
        test.stopTest();
            
    }
    static testMethod void testMethod2(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='NewCheckInCheckOutTrain1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing1010101', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='NewCheckInCheckOutTrain1@noemail.com');
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
        pa.OwnerId = user1.id;
        pa.CheckInStatus__c = '已签到';
        pa.Shop__c = shop.Id;
        //pa.CheckInShop__c = shop.Id;
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = System.today();
        pa.CheckInAddress__c = 'test address';
        pa.SignInTime__c = Time.newInstance(9,30,00,00);
        pa.Check_in_Type__c = 'Onsite';
        pa.Check_in_Status__c = 'Late Check in';
        pa.CheckOutShop__c = shop.Id;
        pa.CheckOutAddress__c = 'test';
        pa.SignOutTime__c = Time.newInstance(18,30,00,00);
        pa.Check_out_Type__c = 'Onsite';
        pa.Check_out_Status__c = 'Check out';
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        INSERT pa;
        System.debug('<------------------>'+pa.OwnerId + '_' + System.today());

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(9, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        insert testPAR;
        
        List<String> attendanceList = new List<String>();
        attendanceList.add(pa.Id);
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Promoter_Attendance_Rule__c = testPAR.id;
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = userInfo.getUserId();
        rp.RecordType__c = '促销员';
        INSERT rp; 

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = pa.ExternalId__c;
        ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        INSERT ist;
        Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
        pai.Promoter_Attendance__c = pa.Id;
        pai.Shop__c = shop.Id;
        pai.Address__c = 'WITHOUT_ADDRESS';
        pai.CheckIn_Date__c =  System.today();
        pai.CheckIn_Time__c = Time.newInstance(9,30,00,00);
        insert pai;
        
        //Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        //testPAR.Shop_Name__c = shop.id;
        
            
        NewCheckInCheckOutTrainController.DataSet cd = new NewCheckInCheckOutTrainController.DataSet();
        cd.Name = 'test';
        cd.Distance = 20;

        List<NewCheckInCheckOutTrainController.DataSet> dList = new List<NewCheckInCheckOutTrainController.DataSet>();
        dList.add(cd);

        NewCheckInCheckOutTrainController.ReturnData  cr = new NewCheckInCheckOutTrainController.ReturnData();
        cr.isSuccess = true;
        cr.addressStr = 'WITHOUT_ADDRESS';
        cr.failMessage = '123131@deloitte.com';
        cr.thisDay = System.today();
        cr.dataList = dList;
        cr.userType = user1.Name;

        List<String> externalIdList = new List<String>();
        externalIdList.add(pa.ExternalId__c);
        String em1 = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        String em2 = 'ENTITY_IS_LOCKED';
        String em3 = 'FIELD_INTEGRITY_EXCEPTION';
        String em4 = 'FIELD_FILTER_VALIDATION_EXCEPTION';
        String em5 = 'DUPLICATE_VALUE';
        String em6 = 'DUPLICATES_DETECTED';

        NewCheckInCheckOutTrainController.DataSet testSet1 = new NewCheckInCheckOutTrainController.DataSet();
        testSet1.Distance = 155.5;

        NewCheckInCheckOutTrainController.DataSet testSet2 = new NewCheckInCheckOutTrainController.DataSet();
        testSet2.Distance = 150.5;

        NewCheckInCheckOutTrainController.DataSet testSet3 = new NewCheckInCheckOutTrainController.DataSet();
        testSet3.Distance = 160.5;
        
        NewCheckInCheckOutTrainController.DataSet testSet4 = new NewCheckInCheckOutTrainController.DataSet();
        testSet4.Distance = null;
        
        test.startTest();
        //system.runAs(user1){
            NewCheckInCheckOutTrainController.initStoreInfo(lati2,lng2,'');
            //NewCheckInCheckOutTrainController.initStoreInfoPromote(lati2,lng2,cr,pa);
            NewCheckInCheckOutTrainController.checkIn(pa.CheckInStatus__c,shop.Id,lati,lng,device,cr.addressStr,'test001','test','test','1','2','3');
                    
            testSet1.compareTo(testSet2);
            testSet1.compareTo(testSet3);
            testSet1.compareTo(testSet4);
            testSet4.compareTo(testSet2);
            //NewCheckInCheckOutTrainController.checkOut(pa.CheckInStatus__c,shop.Id,lati,lng,device,cr.addressStr,'test001','test');
            //NewCheckInCheckOutTrainController.getAttendanceLabel(attendanceList);
            //NewCheckInCheckOutTrainController.getExistAttendance(pa.ExternalId__c);
            //NewCheckInCheckOutTrainController.createUploadFile(pa.id,'test');
            //NewCheckInCheckOutTrainController.geolocationGetAddress(lati2,lng2);
            //NewCheckInCheckOutTrainController.getProperErrorMessage(em1);
            //NewCheckInCheckOutTrainController.getProperErrorMessage(em2);
            //NewCheckInCheckOutTrainController.getProperErrorMessage(em3);
            //NewCheckInCheckOutTrainController.getProperErrorMessage(em4);
            //NewCheckInCheckOutTrainController.getProperErrorMessage(em5);
            //NewCheckInCheckOutTrainController.getProperErrorMessage(em6);
        //}
        test.stopTest();
            
    }
}