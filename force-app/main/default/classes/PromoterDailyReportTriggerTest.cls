@isTest
public class PromoterDailyReportTriggerTest {
    static testMethod void testTriggerMethod(){
        Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
        test.startTest();
        INSERT pdr;
        test.stopTest();
    }
}