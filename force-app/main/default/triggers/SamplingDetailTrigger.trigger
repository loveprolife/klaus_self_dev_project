trigger SamplingDetailTrigger on Sampling_Detail__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new Triggers()
	.bind(Triggers.Evt.beforeinsert, new SamplingDetailHandler())
	.bind(Triggers.Evt.beforeupdate, new SamplingDetailHandler())
	.bind(Triggers.Evt.afterupdate, new SamplingDetailHandler())
	.manage(); 
	
	// [2023-10-16] add by suzeng@deloitte.com.cn
	// new NewSamplingDetailHandler().run();
}