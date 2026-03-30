global class DeletePlannedCompletionRateReportBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    global DeletePlannedCompletionRateReportBatch(String inputYear,String inputMonth) {
        this.year = inputYear;
        this.month = inputMonth;
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }
        this.query = 'SELECT ID FROM Planned_Completion_Rate_Report__c WHERE Year__c=:year AND Month__c=:month';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Planned_Completion_Rate_Report__c> pcrrList) {
        try {
            Database.delete(pcrrList);
        }
        catch (Exception e) {
            System.debug('Batch错误：'+e.getMessage()+e.getLineNumber());
        } 
    }

    global void finish(Database.BatchableContext BC) {

    }
}