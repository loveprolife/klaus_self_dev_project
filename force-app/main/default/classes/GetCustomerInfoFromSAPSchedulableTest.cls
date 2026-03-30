@isTest
private class GetCustomerInfoFromSAPSchedulableTest {
    public static String CRON_EXP = '0 0 1 * * ?';
    static testMethod void testMethod1() {
    	TestDataUtility.createCustomSettings();
    	GetCustomerInfoFromSAPSchedulable invoice = new GetCustomerInfoFromSAPSchedulable();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,invoice); 
    }
}