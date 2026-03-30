/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 01-19-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger PositionTrigger on Position__c (before insert, 
                                        before update, 
                                        before delete, 
                                        after insert, 
                                        after update, 
                                        after delete, 
                                        after undelete) {
    new Triggers()

    //岗位创建后,生成UserGroup,并写入GroupId至岗位
    .bind(Triggers.Evt.beforeinsert, new PositionCreateUserGroupHandler())
    .bind(Triggers.Evt.beforeupdate, new PositionCreateUserGroupHandler())
    .bind(Triggers.Evt.afterdelete, new PositionCreateUserGroupHandler())
    .manage();
}