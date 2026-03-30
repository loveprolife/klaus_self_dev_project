trigger SampleDisplayConfirmTrigger on Sample_Display_Confirm__c (before insert, after insert, before update, after update, before delete) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new SampleDisplayConfirmTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new SampleDisplayConfirmTriggerHandler())
	.bind(Triggers.Evt.beforeupdate, new SampleDisplayConfirmTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new SampleDisplayConfirmTriggerHandler())
	.bind(Triggers.Evt.beforedelete, new SampleDisplayConfirmTriggerHandler())
    .manage();
}