trigger FOBGSSTrigger on FOB_GSS__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new FOBGSSTriggerHandler().run();
}