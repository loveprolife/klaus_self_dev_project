@isTest
private class SchedulableTest {
	public static String CRON_EXP = '0 0 12 * * ?';
    static testMethod void testMethod1() {
    	SAPGetInvoiceSchedulable invoice = new SAPGetInvoiceSchedulable(new List<String>{'8200'},new List<String>{'ZCR1'});
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,invoice); 
    }
    static testMethod void testMethod2(){
    	SAPGetVirtualOrderSchedulable virtualOrder = new SAPGetVirtualOrderSchedulable(new List<String>{'8200'});
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,virtualOrder);
    }
    static testMethod void testMethod3(){
    	SAPGetSalesOrderSchedulable salesOrder = new SAPGetSalesOrderSchedulable(new List<String>{'8200'},new List<String>{'ZCR1'});
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,salesOrder);
    }
    static testMethod void testMethod4(){
    	TestDataUtility.createCustomSettings();
    	SAPGetRevenueCostSchedulable revenueCost = new SAPGetRevenueCostSchedulable(new List<String>{'8200'});
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP,revenueCost);
    }
    static testMethod void testMethod5(){
    	SAPGetPOOrderSchedulable poorder = new SAPGetPOOrderSchedulable(new List<String>{'8110'});
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,poorder);
    }
    static testMethod void testMethod6(){
    	SAPGetDeliveryOrderSchedulable deliveryOrder = new SAPGetDeliveryOrderSchedulable(new List<String>{'8200'},new List<String>{'ZCR1'});
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,deliveryOrder);
    }
    static testMethod void testMethod7(){
    	StrategyCustomerReportBatchSchedulable starategy = new StrategyCustomerReportBatchSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,starategy);
    }
    static testMethod void testMethod8(){
    	SalesTargetBatchSchedulable salesTarget = new SalesTargetBatchSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,salesTarget);
    }
    static testMethod void testMethod9(){
    	RevenueStatementReportBatchSchedulable statement = new RevenueStatementReportBatchSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,statement);
    }
    static testMethod void testMethod10(){
    	QualityCustomerReportBatchSchedulable quality = new QualityCustomerReportBatchSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,quality);
    }
    static testMethod void testMethod11(){
    	OriginalCustomerReportBatchSchedulable original = new OriginalCustomerReportBatchSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,original);
    }
    static testMethod void testMethod12(){
    	CustomerVolumeRevenueReportSchedulable cv = new CustomerVolumeRevenueReportSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,cv);
    }
    static testMethod void testMethod13(){
    	CustomerSchedulable cv = new CustomerSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,cv);
    }

    static testMethod void testMethod14(){
    	InitAttendanceInformationSchedulable cv = new InitAttendanceInformationSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,cv);
    }

    static testMethod void testMethod15(){
    	StoreInspectionReportBatchSchedulable cv = new StoreInspectionReportBatchSchedulable();
    	String jobId = System.schedule('ScheduledApexTest',CRON_EXP,cv);
    }
}