trigger SAPSalesActualPlanTrigger on SAP_Sales_Actual_Plan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new SAPSalesActualPlanTriggerHandler().run();
}