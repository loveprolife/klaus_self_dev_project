public without sharing class ResponsiblePersonShareInvocableMethod{
    @InvocableMethod
    public static void responsiblePersonShare(List<String> salesRegion){
        ResponsiblePersonSchedulableController cis = new ResponsiblePersonSchedulableController(salesRegion[0]);
        SchedulableContext sc;
        cis.execute(sc);

        SupervisorStorePromoterBatch ss = new SupervisorStorePromoterBatch(salesRegion[0]);
        Database.executeBatch(ss);
    }

}