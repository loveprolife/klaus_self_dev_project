trigger SupplementaryInformationTrigger on Supplementary_Information__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  new Triggers()
  .bind(Triggers.Evt.beforeinsert, new SupplementaryInformationHandler())
  .bind(Triggers.Evt.beforeupdate, new SupplementaryInformationHandler())
  .bind(Triggers.Evt.afterinsert, new SupplementaryInformationHandler())
  .bind(Triggers.Evt.afterupdate, new SupplementaryInformationHandler())
  .manage();
}