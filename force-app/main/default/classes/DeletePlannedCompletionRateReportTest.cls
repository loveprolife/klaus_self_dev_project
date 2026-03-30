@isTest
private class DeletePlannedCompletionRateReportTest {
    static testMethod void testMethod1() {
    	ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
        Planned_Completion_Rate_Report__c ocrr = new Planned_Completion_Rate_Report__c();
        ocrr.Management_Customer__c = accId;
        ocrr.Product_Line__c = Label.SACE;
        ocrr.Year__c = '2019';
        ocrr.Month__c = '01';
        Database.insert(ocrr);
        DeletePlannedCompletionRateReportBatch dpcrr = new DeletePlannedCompletionRateReportBatch('2019','1');
         Database.executeBatch(dpcrr,200);
    }
}