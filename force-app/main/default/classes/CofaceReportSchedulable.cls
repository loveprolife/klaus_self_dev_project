public with sharing class CofaceReportSchedulable implements Schedulable{

    public String reportId;
    public CofaceReportSchedulable(String reportId){
        this.reportId = reportId;

    }
    public void execute(SchedulableContext SC){
        System.enqueueJob(new CofaceReportReadyJob(reportId));
    }

}