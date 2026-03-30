trigger ResponsiblePersonTrigger on Responsible_Person__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
    .bind(Triggers.Evt.beforeinsert, new ResponsiblePersonTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new ResponsiblePersonTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new ResponsiblePersonTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new ResponsiblePersonTriggerHandler())
    .bind(Triggers.Evt.afterdelete, new ResponsiblePersonTriggerHandler())
	.manage();  
    if(PhaseIIIUtility.isPhaseIIIUser()) {
	    new NewResponsiblePersonTriggerHandler().run();
    }
     
}