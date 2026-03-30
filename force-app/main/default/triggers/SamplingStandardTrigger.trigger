trigger SamplingStandardTrigger on Sampling_Standard__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new Triggers()
	// .bind(Triggers.Evt.afterInsert, new SamplingStandardHandler())
	// .bind(Triggers.Evt.beforeInsert, new SamplingStandardHandler())
	// .bind(Triggers.Evt.beforeUpdate, new SamplingStandardHandler())
	// .bind(Triggers.Evt.afterUpdate, new SamplingStandardHandler())
	.manage();    
}