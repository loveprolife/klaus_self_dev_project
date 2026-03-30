@isTest
private class PlannedCompletionRateReportShareTest {
    static testMethod void testMethod1() {
    	ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', Email='systemadmin@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin@hisensetest.com'
        );
        Database.insert(user1);

        
        Sales__c sales = new Sales__c();
        sales.Customer__c = accId;
        sales.Product_Line__c = 'TV';
        sales.Sales__c = user1.Id;
        sales.IsKeyUser__c = true;
        Database.insert(sales);

        Planned_Completion_Rate_Report__c ocrr = new Planned_Completion_Rate_Report__c();
        ocrr.Management_Customer__c = accId;
        ocrr.Product_Line__c = Label.SACE;
        ocrr.Year__c = '2019';
        ocrr.Month__c = '01';
        Database.insert(ocrr);

        PlannedCompletionRateReportShareBatch pcrrs = new PlannedCompletionRateReportShareBatch('2019','1');
        //损益表batch
        Database.executeBatch(pcrrs,200);
    }
}