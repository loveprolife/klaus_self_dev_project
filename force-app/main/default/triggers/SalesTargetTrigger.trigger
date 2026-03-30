/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-25-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
trigger SalesTargetTrigger on Sales_Target_Branch_Company_Use__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new SalesTargetTriggerHandler().run();

    new Triggers()

    //岗位共享IsChanges设置
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())
    .manage();
}