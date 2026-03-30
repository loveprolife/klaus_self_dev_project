global without sharing class CreateReportConfigItemBatchSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {

        Date today = Date.today();
        CreateReportConfigurationItemBatch createReportConfigItemBatch = new CreateReportConfigurationItemBatch(today.year() + 1);
        Database.executeBatch(createReportConfigItemBatch);

    }

}