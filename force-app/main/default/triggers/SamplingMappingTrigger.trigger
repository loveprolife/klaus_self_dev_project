trigger SamplingMappingTrigger on Sampling_Mapping__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new Triggers()
	// .bind(Triggers.Evt.afterupdate, new SamplingMappingHandler())
	// .bind(Triggers.Evt.beforeinsert, new SamplingMappingHandler())
	.manage(); 
}