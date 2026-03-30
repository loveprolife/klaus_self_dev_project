trigger ExhibitionArrangementTrigger on Exhibition_Arrangement__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExhibitionArrangementTriggerHandler().run();
}