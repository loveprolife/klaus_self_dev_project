@isTest
private class BulkApiSchedulableTest {
    static testMethod void testMethod1() {
        String CRON_EXP = '0 0 12 * * ?';
        TestDataUtility.createBulkApi();
        String erdat = Datetime.now().format('yyyy-MM-dd');
        BulkApiSchedulable bulkApi= new BulkApiSchedulable(erdat, 1);
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,bulkApi); 
    }

    static testMethod void testMethod2() {
        String CRON_EXP = '0 0 12 * * ?';
        TestDataUtility.createBulkApi();
        String erdat = Datetime.now().addDays(-1).format('yyyy-MM-dd');
        BulkApiSchedulable bulkApi= new BulkApiSchedulable(erdat, 0);
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,bulkApi); 
    }
}