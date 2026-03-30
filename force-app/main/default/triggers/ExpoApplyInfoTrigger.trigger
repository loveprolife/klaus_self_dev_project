trigger ExpoApplyInfoTrigger on ExpoApplyInfo__c(before insert,after insert, before update, after update, before delete, after delete) {
    new ExpoApplyInfoTriggerHander().run();
}