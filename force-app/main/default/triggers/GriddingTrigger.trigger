/**
 * @description       : 
 * @author            : wfc
 * @group             : 
 * @last modified on  : 02-23-2022
**/
trigger GriddingTrigger on Gridding__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
    .bind(Triggers.Evt.afterupdate, new GriddingTriggerHandler())
    .bind(Triggers.Evt.beforeinsert, new GriddingTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new GriddingTriggerHandler())

    .manage();
}