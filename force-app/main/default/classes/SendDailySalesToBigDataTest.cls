@isTest
private class SendDailySalesToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.sales_region__c = 'Hisense Indonesia';
        insert store;

        User promoter = new User();
        promoter.Username = 'testPromoterUser12138@test004.com';
        promoter.lastname = 'testPromoterUser12138';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name = 'Indonesia Promoter'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Country = 'ID';
        promoter.sales_region__c = 'Hisense Indonesia';
        insert promoter;

        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
        promoterRes.Promoter_Attendance_Rule__c = par.Id;
        insert promoterRes;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today();
        insert report;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 600;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 3;
        sales1.ResponsiblePerson__c = [SELECT ID FROM Responsible_Person__c WHERE RecordType__c = '促销员'][0].Id;
        insert sales1;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendDailySalesToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendDailySalesToBigData.adoPost();
        Test.stopTest();
    }
}