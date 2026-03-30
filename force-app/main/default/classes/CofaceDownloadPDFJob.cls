public without sharing class CofaceDownloadPDFJob implements Queueable, Database.AllowsCallouts{
    private String reportId;
    public CofaceDownloadPDFJob(String reportId){
        this.reportId = reportId;
    }

    public void execute(QueueableContext context){
        // Return early if no id
        System.debug('wwwwww----CofaceDownloadPDFJob----' + reportId);
        if (reportId == null){
            return;
        }
        CofaceModuleController.downloadPDFByReportId(reportId);
        // 异步调用接口获取json数据
        System.enqueueJob(new CofaceDownloadJsonJob(reportId));
    }

}