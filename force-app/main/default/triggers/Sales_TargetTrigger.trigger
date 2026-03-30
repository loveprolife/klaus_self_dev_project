/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-25-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
trigger Sales_TargetTrigger on Sales_Target__c (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete) {
    new Triggers()

    //岗位共享IsChanges设置
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())
    .manage();
}