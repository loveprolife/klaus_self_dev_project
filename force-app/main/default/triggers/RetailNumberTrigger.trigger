trigger RetailNumberTrigger on Retail_Number__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
   if(PhaseIIIUtility.isPhaseIIIUser()) {
	   new RetailNumberTriggerHandler().run();
    }
   }