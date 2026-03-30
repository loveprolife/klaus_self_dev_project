trigger StockItemTrigger on StockItem__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    if(PhaseIIIUtility.isPhaseIIIUser()) {
        new InventoryItemTriggerHandler().run();
    }
}