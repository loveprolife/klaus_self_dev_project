trigger ChannelTrigger on Channel__c (after insert,before insert, after update,before update) {
    new ChannelTriggerHandler().run();
}