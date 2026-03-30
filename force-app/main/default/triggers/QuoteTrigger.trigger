trigger QuoteTrigger on Quote__c(before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    if(Label.Trigger_Switch =='ON'){
         new QuoteTriggerHandler().run();
    }
}