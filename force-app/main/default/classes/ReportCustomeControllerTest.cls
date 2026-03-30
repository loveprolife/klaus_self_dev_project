@isTest
public class ReportCustomeControllerTest {
    @isTest
    Static void testMethod1(){
        Test.startTest();
        Report_Custom__c rc = new Report_Custom__c();
        rc.Report_Name__c = 'test01';
        rc.Report_Status__c = 'Updating';
        rc.Batch_Class__c = 'PrototypeReportDeleteBatch';
        rc.Parameter__c = '11';
        insert rc;

        Report_Custom__c rc1 = new Report_Custom__c();
        rc1.Report_Name__c = 'test01';
        rc1.Report_Status__c = 'Updating';
        rc1.Batch_Class__c = 'CustomerProductSalesReportDelBatch';
        rc1.Parameter__c = '8110;2024-05-01';
        insert rc1;

        Report_Custom__c rc2 = new Report_Custom__c();
        rc2.Report_Name__c = 'test01';
        rc2.Report_Status__c = 'Updating';
        rc2.Batch_Class__c = 'CustomerProductSalesReportDelBatch';
        rc2.Parameter__c = '8110';
        insert rc2;

        Report_Custom__c rc3 = new Report_Custom__c();
        rc3.Report_Name__c = 'test01';
        rc3.Report_Status__c = 'Updating';
        rc3.Batch_Class__c = 'test01';
        insert rc3;

        ReportCustomeController.getReportCustomData();
        ReportCustomeController.updateReportCustom(rc);
        ReportCustomeController.updateReportCustom(rc1);
        ReportCustomeController.updateReportCustom(rc2);
        ReportCustomeController.updateReportCustom(rc3);

        Test.stopTest();
    }
}