trigger ProductLineTrigger on Customer_Product_line__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ProductLineTriggerHandler().run();
}