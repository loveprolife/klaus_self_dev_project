trigger InventoryTrigger on Inventory__c (before insert, before update, before delete, after insert, after update) {
    if(PhaseIIIUtility.isPhaseIIIUser()) {
    new InventoryTriggerHandler().run();
    }
}