trigger SAPSalesActualTrigger on SAP_Sales_Actual__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new SAPSalesActualTriggerHandler().run();
}