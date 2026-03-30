trigger DailyInspectionReportTrigger on Daily_Inspection_Report__c (before insert, before update, before delete, after insert, after update) {
    new DailyInspectionReportTriggerHandler().run();
}