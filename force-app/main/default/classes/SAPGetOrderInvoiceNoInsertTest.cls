@isTest
public class SAPGetOrderInvoiceNoInsertTest{
    static testMethod void testMethod1(){
        TestDataUtility.createCustomSettings();
        String CRON_EXP = '0 0 12 * * ?';
        SAPGetOrderInvoiceNoInsertSchedulable invoice = new SAPGetOrderInvoiceNoInsertSchedulable('8400', 'ALL', '', '', 0);
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, invoice);

        SAPGetOrderInvoiceNoInsertSchedulable invoice1 = new SAPGetOrderInvoiceNoInsertSchedulable('8400,8420,8430,8450,8460', 'ALL', 0);
        String jobId1 = System.schedule('ScheduledApexTest1', CRON_EXP, invoice1);

        SAPGetOrderInvoiceNoInsert.executionInterface(new List<String>{ '8400', '8420', '8430', '8450', '8460' }, '', '', new List<String>{ 'ALL' }, 0);
    }

}