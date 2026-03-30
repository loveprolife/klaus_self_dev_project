/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger PromoterDailyReportTrigger on Promoter_Daily_Report__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  new Triggers()
  .bind(Triggers.Evt.beforeinsert, new PromoterDailyReportHandler())
  .bind(Triggers.Evt.beforeupdate, new PromoterDailyReportHandler())
  .bind(Triggers.Evt.afterinsert, new PromoterDailyReportHandler())
  .bind(Triggers.Evt.afterupdate, new PromoterDailyReportHandler())

    //岗位共享IsChanges设置 chenpeng@deloitte.com.cn 20220221 add
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())
  .manage();
  //库存管理 tiger 20230614 
  if(PhaseIIIUtility.isPhaseIIIUser()) {
	   new PromoterDailyReportHandler2().run();
    }
  
}