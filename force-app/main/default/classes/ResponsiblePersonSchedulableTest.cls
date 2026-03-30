@isTest
public class ResponsiblePersonSchedulableTest{
    @isTest
    Static void testMethod1(){
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = 'testShop';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        testShop.Sales_Region__c = 'Hisense USA';

        Shop__c testShop2 = new Shop__c();
        testShop2.name = 'testShop2';
        testShop2.City__c = '重庆';
        testShop2.Account__c = customerTest.id;
        testShop2.Shop_Level__c = 'A';
        testShop2.Sales_Region__c = 'Hisense USA';
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
            Sales_Region__c = 'Hisense USA', 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testPromoter111@test.com'
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
            Sales_Region__c = 'Hisense USA', 
            timezonesidkey = 'America/Los_Angeles', 
            username = 'testPromoter2222@test.com'
        );
        User floorwalker = new User(
            alias = '巡店员', 
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
            username = 'testFloorwarker@test.com'
        );

        User floorwalker2 = new User(
            alias = '巡店员', 
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
            username = 'testFloorwarker2222@test.com'
        );

        insert new List<User>{ promoter, promoter2, floorwalker, floorwalker2 };

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

        Responsible_Person__c resPerson = new Responsible_Person__c(
            Shop_Name__c = testShop2.id, 
            Principal__c = floorwalker.Id, 
            RecordType__c = '巡店员'
        );

        Responsible_Person__c resPerson22 = new Responsible_Person__c(
            Shop_Name__c = testShop.id, 
            Principal__c = floorwalker2.Id, 
            RecordType__c = '巡店员'
        );
        insert new List<Responsible_Person__c>{ testResponsiblePerson, testResponsiblePerson2, resPerson, resPerson22 };

        ResponsiblePersonSchedulableController cis = new ResponsiblePersonSchedulableController('Hisense USA');
        SchedulableContext sc;
        cis.execute(sc);

        ResponsiblePersonShareInvocableMethod.responsiblePersonShare(new List<String>{'Hisense USA'});
    }

}