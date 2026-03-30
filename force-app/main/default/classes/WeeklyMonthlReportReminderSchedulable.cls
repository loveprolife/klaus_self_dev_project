global without sharing class WeeklyMonthlReportReminderSchedulable implements Schedulable {
    
    public String salesRegion;
    public WeeklyMonthlReportReminderSchedulable(String salesRegion) {
        this.salesRegion = salesRegion;
    }

    global void execute(SchedulableContext sc) {

        WeeklyMonthlReportReminderBatch reportReminderBatch = new WeeklyMonthlReportReminderBatch(salesRegion);
        Database.executeBatch(reportReminderBatch);

    }

}