trigger SampleRemovalTrigger on Sample_Removal__c (before insert, before update, after update, before delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new SampleRemovalTriggerHandler())
	.bind(Triggers.Evt.beforeupdate, new SampleRemovalTriggerHandler())
	.bind(Triggers.Evt.afterupdate, new SampleRemovalTriggerHandler())
	.bind(Triggers.Evt.beforedelete, new SampleRemovalTriggerHandler())
	.manage();
}