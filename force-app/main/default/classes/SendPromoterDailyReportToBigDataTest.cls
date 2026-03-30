@isTest
private class SendPromoterDailyReportToBigDataTest {
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

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today();
        insert report;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2050-02-10 00:00:00"}');
		SendPromoterDailyReportToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendPromoterDailyReportToBigData.adoPost();
        Test.stopTest();
    }
}