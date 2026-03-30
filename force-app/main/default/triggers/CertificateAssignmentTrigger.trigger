trigger CertificateAssignmentTrigger on Expo_Certificate_Assignment__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new CertificateAssignmentTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new CertificateAssignmentTriggerHandler())
    .bind(Triggers.Evt.afterupdate,  new CertificateAssignmentTriggerHandler())
    .bind(Triggers.Evt.afterinsert,  new CertificateAssignmentTriggerHandler())
	.manage();
}