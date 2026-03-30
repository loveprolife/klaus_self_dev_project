@isTest
public class NewPromoterDailyReportTriggerHelperTest {

    @isTest
    public static void test() {
        
        Test.startTest();
        
        NewTestDataUtility.makePromoterDailyReportData();
        Account customer = NewTestDataUtility.customer;
        Promoter_Daily_Report__c report = NewTestDataUtility.report;
        Shop__c store = new Shop__c();
        store.Account__c = customer.Id;
        insert store;
        report.Shop__c = store.Id;
        update report;
        NewPromoterDailyReportTriggerHelper.afterApproved(new List<Promoter_Daily_Report__c>{report}, new List<Promoter_Daily_Report__c> {new Promoter_Daily_Report__c(
        	Id = report.Id,
            Status__c = 'Approved'
        )});
        Test.stopTest();
    }
}