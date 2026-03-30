/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 01-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger PositionMemberTrigger on Position_Member__c (before insert,
                                                     before update,
                                                     before delete,
                                                     after insert,
                                                     after update,
                                                     after delete) {
    new Triggers()

    //创建岗位成员时,并创建小组用户, 检查是否存在重复
    .bind(Triggers.Evt.beforeinsert, new PositionMemberCreateHandler())
    .bind(Triggers.Evt.afterinsert, new PositionMemberCreateHandler())

    // //岗位成员删除时, 小组用户同步删除
    .bind(Triggers.Evt.afterdelete, new PositionMemberDeleteHandler())
    .manage();
}