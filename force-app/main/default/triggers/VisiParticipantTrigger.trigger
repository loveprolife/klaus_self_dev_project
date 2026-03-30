trigger VisiParticipantTrigger on Visit_Participant__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new VisiParticipantTriggerHandler().run();
}