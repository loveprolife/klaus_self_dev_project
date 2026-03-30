/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-17-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger MessageBoardReadTrigger on Shop_Message_Board__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete
) {
    new Triggers()

    //岗位创建后,生成UserGroup,并写入GroupId至岗位
    .bind(Triggers.Evt.afterinsert, new MessageBoardReadTriggerHandler())
    .manage();
}