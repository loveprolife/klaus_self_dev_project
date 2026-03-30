trigger SalesTrigger on Sales__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    new SalesTriggerHandler().run();
    if(Label.Trigger_Sales_Switch == 'ON') {
        new SalesTriggerShareDataHandler().run();
    }
}