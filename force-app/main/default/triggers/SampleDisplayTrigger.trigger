trigger SampleDisplayTrigger on Sample_Display__c (before insert, before update, after insert, after update, before delete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new SampleDisplayTriggerHandler())
	.bind(Triggers.Evt.beforeupdate, new SampleDisplayTriggerHandler())
	.bind(Triggers.Evt.afterinsert, new SampleDisplayTriggerHandler())
	.bind(Triggers.Evt.afterupdate, new SampleDisplayTriggerHandler())
	.bind(Triggers.Evt.beforedelete, new SampleDisplayTriggerHandler())
	.manage();
}