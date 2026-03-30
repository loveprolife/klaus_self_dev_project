trigger WeekResearchTrigger on Week_Research__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
 new Triggers()
  .bind(Triggers.Evt.beforeinsert, new WeekResearchHandler())
  .bind(Triggers.Evt.beforeupdate, new WeekResearchHandler())
  .bind(Triggers.Evt.afterinsert, new WeekResearchHandler())
  .bind(Triggers.Evt.afterupdate, new WeekResearchHandler())
  .manage();
}