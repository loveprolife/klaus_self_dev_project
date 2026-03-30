/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-07-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger SamplingInspectionTrigger on Sampling_Inspection__c (before insert,  before update, after update) {
    new Triggers()

    //没有绑定出样明细
    .bind(Triggers.Evt.beforeinsert, new SamplingInspectionHandler())
    .bind(Triggers.Evt.beforeupdate, new SamplingInspectionHandler())

    //岗位共享IsChanges设置
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())
    .manage();
}