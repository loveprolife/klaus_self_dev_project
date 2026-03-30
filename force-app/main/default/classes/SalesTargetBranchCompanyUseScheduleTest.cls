@isTest
private class SalesTargetBranchCompanyUseScheduleTest {
    static testMethod void testMethod1() {
    	String CRON_EXP = '0 0 12 * * ?';
        SalesTargetBranchCompanyUseSchedule starategy = new SalesTargetBranchCompanyUseSchedule();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,starategy);
    }
}