trigger FootCountInquiryTrigger on FootCountInquiry__c (before insert,after insert, before update, after update, before delete, after delete) {
	new FootCountInquiryTriggerHandler().run();
}