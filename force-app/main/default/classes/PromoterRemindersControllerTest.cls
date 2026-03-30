@isTest
public without sharing class PromoterRemindersControllerTest {
    @IsTest
    static void testMethod1(){
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Shop__c testShop2 = new Shop__c();
        testShop2.name = 'test';
        testShop2.City__c = '重庆';
        testShop2.Account__c = customerTest.id;
        testShop2.Shop_Level__c = 'A';
        Insert testShop2;
        
        String profileName = 'Chile Promoter'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test1230000000000@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123000000000000000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test123000000@noemail.com');
        INSERT user1;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;
        
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        testResponsiblePerson.Shop_Name__c = testShop.id;
        testResponsiblePerson.Principal__c = user1.Id;
        testResponsiblePerson.RecordType__c = '促销员';
        testResponsiblePerson.Promoter_Attendance_Rule__c = testPAR.Id;
        Insert testResponsiblePerson;
        
        Responsible_Person__c testResponsiblePerson2 = new Responsible_Person__c();
        testResponsiblePerson2.Shop_Name__c = testShop2.id;
        testResponsiblePerson2.Principal__c = user1.Id;
        testResponsiblePerson2.RecordType__c = '促销员';
        testResponsiblePerson2.Promoter_Attendance_Rule__c = testPAR.Id;
        Insert testResponsiblePerson2;

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today();
        testReport1.Status__c = 'New';
        Insert testReport1;

        List<Market__c> marketList = new List<Market__c>();
        Date today = System.today();
        DateTime todayDT = (DateTime)today;
        Integer todayWeek = Integer.valueOf(todayDT.format('u'));
        Date monday = today.addDays(-todayWeek+1);
        Date friday = monday.addDays(4);
        List<Date> weeklyDateList = new List<Date>();
        for (Integer i = 0; i < 4; i++) {
            weeklyDateList.add(monday.addDays(-7*i));
        }
        for (Date item : weeklyDateList) {
            Market__c testMarketReport1 = New Market__c();
            testMarketReport1.Shop__c = testShop.id;
            testMarketReport1.OwnerId = user1.id;
            testMarketReport1.Report_Date__c = item;
            testMarketReport1.Status__c = 'New';
            marketList.add(testMarketReport1);
        }

        // Date today = System.today();
        Date thisMonth1st = Date.newInstance(today.year(), today.month(), 1);
        Date thisMonth25th = Date.newInstance(today.year(), today.month(), 25);
        Date lastMonth1st = thisMonth1st.addMonths(-1);
        
        List<Date> monthDateList = new List<Date>();
        monthDateList.add(thisMonth1st);
        monthDateList.add(lastMonth1st);
        // Date thisMonthReportDate = PromoterRemindersController.getLatestMonthlyReportDate(System.today());
        for (Date item : monthDateList) {
            Market__c testMarketReport1 = New Market__c();
            testMarketReport1.Shop__c = testShop.id;
            testMarketReport1.OwnerId = user1.id;
            testMarketReport1.Report_Date__c = item;
            testMarketReport1.Status__c = 'New';
            marketList.add(testMarketReport1);
        }
        Insert marketList;

        String InHouseShare = Schema.PromoterShare__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('InHouseShare').getRecordTypeId();
        String ShelfShare = Schema.PromoterShare__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('ShelfShare').getRecordTypeId();
    
        List<Shop_Retail_Detail__c> srdList = new List<Shop_Retail_Detail__c>();
        List<MarketInsight__c> miList = new List<MarketInsight__c>();
        List<PromoterShare__c> psIHList = new List<PromoterShare__c>();
        List<PromoterShare__c> psSFList = new List<PromoterShare__c>();
        for (Market__c market : marketList) {
            Shop_Retail_Detail__c srd = new Shop_Retail_Detail__c();
            srd.Market__c = market.Id;
            srd.PromoterDailyReport__c = testReport1.Id;
            srdList.add(srd);

            MarketInsight__c mi = new MarketInsight__c();
            mi.Market__c = market.Id;
            miList.add(mi);

            PromoterShare__c psIH = new PromoterShare__c();
            psIH.recordTypeId = InHouseShare;
            psIH.Market__c = market.Id;
            psIHList.add(psIH);

            PromoterShare__c psSF = new PromoterShare__c();
            psSF.recordTypeId = ShelfShare;
            psSF.Market__c = market.Id;
            psSFList.add(psSF);

        }
        Insert srdList;
        Insert miList;
        Insert psIHList;
        Insert psSFList;

        Test.startTest();
        System.runAs(user1){
            PromoterRemindersController.getInitData();
        }
        Test.stopTest();
        
    }
}