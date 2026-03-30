public without sharing class CofaceDownloadJsonJob implements Queueable, Database.AllowsCallouts{
    private String reportId;
    public CofaceDownloadJsonJob(String reportId){
        this.reportId = reportId;
    }

    public void execute(QueueableContext context){
        // Return early if no id
        System.debug('wwwwww----CofaceDownloadJsonJob----' + reportId);
        if (reportId == null){
            return;
        }
        CofaceModuleController.downloadJsonByReportId(reportId);
    }
}