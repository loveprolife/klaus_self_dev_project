trigger WeekQuestionItemTrigger on Week_Question_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Triggers()
    .bind(Triggers.Evt.afterinsert, new WeekQuestionItemHandler())
    .bind(Triggers.Evt.afterupdate, new WeekQuestionItemHandler())
    
	.manage();
}