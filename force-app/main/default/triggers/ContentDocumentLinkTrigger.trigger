trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, 
    after insert, after update, after delete, after undelete) {
    new Triggers()
	.bind(Triggers.Evt.beforeinsert, new ContentDocumentLinkTriggerHandler())
    .bind(Triggers.Evt.beforeupdate, new ContentDocumentLinkTriggerHandler())
    .bind(Triggers.Evt.afterupdate, new ContentDocumentLinkTriggerHandler())
    .bind(Triggers.Evt.afterinsert, new ContentDocumentLinkTriggerHandler())
    .bind(Triggers.Evt.beforedelete, new ContentDocumentLinkTriggerHandler())
	.manage();
}