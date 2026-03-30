trigger PODTrigger on POD__C (before insert, after insert, before update, after update, before delete) {
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new PODTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new PODTriggerHandler())
    .manage();
}