trigger GoodsInOutTrigger on GoodsInOut__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    if(PhaseIIIUtility.isPhaseIIIUser()) {
        new GoodsInAndOutHandller().run();
    }
}