@isTest
public class SupervisorPromoterAttendanceTest{
    @TestSetup
    static void makeData(){
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        insert customerTest;

        Channel_item__c channelItem = new Channel_item__c();
        channelItem.Channel_Name__c = 'YAMADA';
        insert channelItem;

        Shop__c testShop = new Shop__c();
        testShop.name = 'testShop';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        testShop.Sales_Region__c = 'Hisense South Africa';
        testShop.Channel_item__c = channelItem.Id;

        Shop__c testShop2 = new Shop__c();
        testShop2.name = 'testShop2';
        testShop2.City__c = '重庆';
        testShop2.Account__c = customerTest.id;
        testShop2.Shop_Level__c = 'A';
        testShop2.Sales_Region__c = 'Hisense South Africa';
        testShop2.Channel_item__c = channelItem.Id;
        insert new List<Shop__c>{ testShop, testShop2 };

        Id profileId = [SELECT Id
                        FROM profile
                        WHERE Name = 'South Africa Promoter'][0].Id;
        User promoter = new User(
            alias = '促销员', 
            email = 'testPromoter@test.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'test', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            Sales_Region__c = 'Hisense South Africa', 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testPromoter@test.com'
        );
        User promoter2 = new User(
            alias = '促销员2', 
            email = 'testPromoter2@test.com', 
            emailencodingkey = 'UTF-8', 
            lastname = 'test', 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            profileid = profileId, 
            country = 'United States', 
            IsActive = true, 
            Sales_Region__c = 'Hisense South Africa', 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testPromoter2@test.com'
        );
        insert new List<User>{ promoter, promoter2 };

        // 考勤规则
        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(9, 0, 0, 0);
        testPAR.End_time__c = Time.newInstance(19, 0, 0, 0);
        testPAR.Name = 'testPAR';
        insert testPAR;

        // 门店负责人
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c(
            Shop_Name__c = testShop.id, 
            Principal__c = promoter.Id, 
            RecordType__c = '促销员', 
            Promoter_Attendance_Rule__c = testPAR.Id
        );
        Responsible_Person__c testResponsiblePerson2 = new Responsible_Person__c(
            Shop_Name__c = testShop2.id, 
            Principal__c = promoter2.Id, 
            RecordType__c = '促销员', 
            Promoter_Attendance_Rule__c = testPAR.Id
        );
        Responsible_Person__c testResponsiblePerson3 = new Responsible_Person__c(
            Shop_Name__c = testShop.id, 
            Principal__c = promoter.Id, 
            RecordType__c = '巡店员'
        );
        Responsible_Person__c testResponsiblePerson4 = new Responsible_Person__c(
            Shop_Name__c = testShop2.id, 
            Principal__c = promoter2.Id, 
            RecordType__c = '巡店员'
        );
        insert new List<Responsible_Person__c>{ testResponsiblePerson, testResponsiblePerson2, testResponsiblePerson3, testResponsiblePerson4 };

        // 排班计划
        SchedulingTask__c task = new SchedulingTask__c(
            IsImport__c = false, 
            Scheduling_Date__c = Date.today(), 
            Responsible_person__c = testResponsiblePerson.Id, 
            Store__c = testShop.Id, 
            User__c = UserInfo.getUserId(), 
            Status__c = 'Scheduled', 
            Promoter_Attendance_Rule__c = testPAR.Id
        );
        SchedulingTask__c task2 = new SchedulingTask__c(
            IsImport__c = false, 
            Scheduling_Date__c = Date.today(), 
            Responsible_person__c = testResponsiblePerson2.Id, 
            Store__c = testShop2.Id, 
            User__c = UserInfo.getUserId(), 
            Status__c = 'Scheduled', 
            Promoter_Attendance_Rule__c = testPAR.Id
        );
        insert new List<SchedulingTask__c>{ task, task2 };

        // 考勤记录
        Promoter_Attendance__c attendance = new Promoter_Attendance__c(
            Shop__c = testShop.Id, 
            CheckIn_Date__c = Date.today(), 
            SignInTime__c = Time.newInstance(9, 0, 0, 0), 
            Check_out_Status__c = 'Check in', 
            CheckInStatus__c = '已签到', 
            ExternalId__c = promoter.Id + '_' + String.valueOf(Date.today()), 
            RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId()
        );
        Promoter_Attendance__c attendance2 = new Promoter_Attendance__c(
            Shop__c = testShop2.Id, 
            CheckOutShop__c = testShop2.Id, 
            CheckIn_Date__c = Date.today(), 
            SignInTime__c = Time.newInstance(9, 0, 0, 0), 
            SignOutTime__c = Time.newInstance(19, 0, 0, 0), 
            Check_out_Status__c = 'Check in', 
            CheckInStatus__c = '已签到签退', 
            ExternalId__c = promoter2.Id + '_' + String.valueOf(Date.today()), 
            RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId()
        );
        insert new List<Promoter_Attendance__c>{ attendance, attendance2 };
        attendance = [SELECT Id, Shop__c, ExternalId__c, Check_in_Status__c, CreatedBy.Name, Owner.Name, CheckOutShop__c, CheckIn_Date__c, SignOutTime__c, Check_out_Status__c, CheckInStatus__c, RecordType.Name
                      FROM Promoter_Attendance__c
                      WHERE Id = :attendance.Id];
        attendance2 = [SELECT Id, Shop__c, ExternalId__c, Check_in_Status__c, CreatedBy.Name, Owner.Name, CheckOutShop__c, CheckIn_Date__c, SignOutTime__c, Check_out_Status__c, CheckInStatus__c, RecordType.Name
                       FROM Promoter_Attendance__c
                       WHERE Id = :attendance2.Id];
        System.debug('AutoCheckOutBatchTest -> attendance: ' + attendance);
        System.debug('AutoCheckOutBatchTest -> attendance2: ' + attendance2);

        // 签到记录
        Promoter_Attendance_Information__c checkInRecord = new Promoter_Attendance_Information__c(
            Promoter_Attendance__c = attendance.Id, 
            Shop__c = testShop.Id, 
            CheckIn_Date__c = Date.today(), 
            CheckIn_Time__c = Time.newInstance(9, 0, 0, 0), 
            IsSystemAuto__c = true, 
            Type__c = 'Check in', 
            Status__c = 'Check in'
        );

        Promoter_Attendance_Information__c checkInRecord2 = new Promoter_Attendance_Information__c(
            Promoter_Attendance__c = attendance2.Id, 
            Shop__c = testShop2.Id, 
            CheckIn_Date__c = Date.today(), 
            CheckIn_Time__c = Time.newInstance(9, 0, 0, 0), 
            IsSystemAuto__c = true, 
            Type__c = 'Check in', 
            Status__c = 'Check in'
        );

        Promoter_Attendance_Information__c checkOutRecord = new Promoter_Attendance_Information__c(
            Promoter_Attendance__c = attendance2.Id, 
            Shop__c = testShop2.Id, 
            CheckIn_Date__c = Date.today(), 
            CheckIn_Time__c = Time.newInstance(19, 0, 0, 0), 
            IsSystemAuto__c = true, 
            Type__c = 'Check out', 
            Status__c = 'Check out'
        );
        insert new List<Promoter_Attendance_Information__c>{ checkInRecord, checkInRecord2, checkOutRecord };
    }

    @isTest
    static void testMethod1(){
        SupervisorStorePromoterBatch sspb = new SupervisorStorePromoterBatch('Hisense South Africa');
        Database.executeBatch(sspb);
        SupervisorPromoterAttendanceBatch spab = new SupervisorPromoterAttendanceBatch('Hisense South Africa');
        Database.executeBatch(spab);
        SupervisorStorePromoterBatch sspb1 = new SupervisorStorePromoterBatch('Hisense South Africa', String.valueOf(Date.today()));
        Database.executeBatch(sspb1);
    }

}