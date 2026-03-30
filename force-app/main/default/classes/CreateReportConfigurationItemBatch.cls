public class CreateReportConfigurationItemBatch implements Database.Batchable<sObject> {

    public Integer year;
    public CreateReportConfigurationItemBatch(Integer year) {
        this.year = year;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, RecordTypeId, RecordType.Name, FirstDayOfWeeklyReport__c,  Active__c ';
        query += 'FROM ReportConfigurationInformation__c WHERE Active__c = true';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<ReportConfigurationInformation__c> scope){
        try {
            List<String> configIdList = new LisqContainer(scope).selectsField('Id');
            System.debug('CreateReportConfigurationItemBatch ---> year : ' + year);
            List<ReportConfigurationItem__c> configItemList = [SELECT Id, Name, Year__c, ReportConfigurationInformation__c, Cyclical__c, StartDay__c, EndDate__c
                                                                FROM ReportConfigurationItem__c  
                                                                WHERE ReportConfigurationInformation__c IN :configIdList AND Year__c = :year
                                                                ORDER BY Cyclical__c DESC];
            Map<String, LisqContainer> configItemGroupByConfig = new LisqContainer(configItemList).GroupByS('ReportConfigurationInformation__c');
            List<ReportConfigurationInformation__c> configList = new List<ReportConfigurationInformation__c>();
            for(ReportConfigurationInformation__c item : scope) {
                if(!configItemGroupByConfig.containsKey(item.Id)) {
                    configList.add(item);
                }
            }
            ReportConfigurationTriggerHandlerHelper.createItems(new List<ReportConfigurationInformation__c>(), configList, true, year);
        }
        catch (Exception e) {
            System.debug('CreateReportConfigurationItemBatch Error : '+ e.getMessage() + e.getLineNumber());
        } 
    }
    public void finish(Database.BatchableContext bc){
    }
}