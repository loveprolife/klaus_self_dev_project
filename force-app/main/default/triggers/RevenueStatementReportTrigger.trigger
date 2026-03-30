/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger RevenueStatementReportTrigger on Revenue_Statement_Report__c (
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