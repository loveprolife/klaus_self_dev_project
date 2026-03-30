trigger InternalRegistrationTrigger on Internal_Registration__c(before insert,after insert, before update, after update, before delete, after delete) {
     new InternalRegistrationTriggerHander().run();
}