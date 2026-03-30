trigger ReportConfigurationInformationTrigger on ReportConfigurationInformation__c (before insert, after insert, before update, after update, before delete, after delete) {
	new ReportConfigurationTriggerHandler().run();
}