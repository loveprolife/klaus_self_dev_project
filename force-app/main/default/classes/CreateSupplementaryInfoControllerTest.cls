@IsTest
private class CreateSupplementaryInfoControllerTest {
    @IsTest
    static void testHasCheckInAndOut(){
        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'InspectorAttendace'][0].Id;
        Id recordId1 = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckInSupplementary'][0].Id;
        Id recordId2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckOutSupplementary'][0].Id;

        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Admin'][0].Id;

        User userManager = new User(alias = 'Admin', email='testUser9988@gmail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testUser9988@gmail.com');
        insert userManager;

        User user1 = new User(alias = 'Admin', email='testUser9989@gmail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testUser9989@gmail.com', ManagerId = userManager.Id);
        insert user1;

        Account acc = new Account(
                            Name = 'testname');
        insert acc;

        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = system.today() - 1;
        dir.OwnerId = user1.Id;
        INSERT dir;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        insert shop;

        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.ApprovalStatus__c ='未创建';
        pa.AddCheckInReason__c = 'test AddCheckInReason';
        pa.Shop__c = shop.Id;
        pa.Add_Check_Shop__c = shop.Id;
        pa.CheckInStatus__c = '已签退';
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = system.today();
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        pa.RecordTypeId = recordId;
        pa.Daily_Inspection_Report__c = dir.Id;
        pa.AddCheckSignInTime__c = null;
        pa.SignInTime__c = Time.newInstance(18, 30, 00, 00);        
        INSERT pa;

        
        Test.startTest();
        CreateSupplementaryInfoController.RecordData recordData = new CreateSupplementaryInfoController.RecordData();
        recordData.checkInBoxFieldValue = true;
        recordData.checkOutBoxFieldValue = true;
        recordData.inShop = shop.Id;
        recordData.outShop = shop.Id;
        recordData.selectedDate = String.valueOf(System.today());
        recordData.signInTime = String.valueOf(Time.newInstance(8, 30, 00, 00));
        recordData.signOutTime = String.valueOf(Time.newInstance(18, 30, 00, 00));
        CreateSupplementaryInfoController.submitRecords(Json.serialize(recordData));
    
        Supplementary_Information__c checkIn = new Supplementary_Information__c();
        checkIn.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        checkIn.Shop__c = shop.Id;
        checkIn.Status__c='未提交补签申请';
        checkIn.Attendance__c = pa.Id;
        checkIn.RecordTypeId = recordId1;
        checkIn.Reson__c = 'test';
        insert checkIn;

        Supplementary_Information__c checkOut = new Supplementary_Information__c();
        checkOut.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        checkOut.Shop__c = shop.Id;
        checkOut.Status__c='未提交补签申请';
        checkOut.Attendance__c = pa.Id;
        checkOut.RecordTypeId = recordId2;
        checkOut.Reson__c = 'test';
        insert checkOut;

        CreateSupplementaryInfoController.submitRecords(Json.serialize(recordData));
        Test.stopTest();
        
    }
}