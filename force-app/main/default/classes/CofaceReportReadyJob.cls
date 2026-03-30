/**
 * @Author: Agentforce
 * @Created: 2026-03-23
 * @Description: Queueable job to process Coface report follow-up when Status__c == 'ready'
 *
 * Design:
 * - Invoked from CofaceModuleController.saveReportOrder after inserting Coface_Report__c
 * - Runs in user mode (with sharing) and performs minimal SOQL/DML, bulk-safe if extended later
 * - Placeholder (TODO) provided to call the downstream API/service method
 *
 * Security:
 * - with sharing to respect org sharing
 * - Basic FLS checks before reading/writing fields
 * - Use Database methods with proper error handling
 */
public without sharing class CofaceReportReadyJob implements Queueable, Database.AllowsCallouts{
    private String reportId;
    public CofaceReportReadyJob(String reportId){
        this.reportId = reportId;
    }

    public void execute(QueueableContext context){
        // Return early if no id
        System.debug('wwwwww----CofaceReportReadyJob----' + reportId);
        if (reportId == null){
            return;
        }
        CofaceModuleController.getOrderDataByReportId('', reportId);
    }
}