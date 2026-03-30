trigger ScoreSheetTrigger on Score_Sheet__c(before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    new ScoreSheetTriggerHandler().run();
}