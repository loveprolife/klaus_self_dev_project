public class CommissionDetailTriggerHandlerHelper {

    private static final Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.CommissionModule__c.getRecordTypeInfosByDeveloperName();

    public static void createCommissionModules(List<CommissionDetail__c> newList) {
        List<CommissionModule__c> modules = new List<CommissionModule__c>();
        for (CommissionDetail__c cd : newList) {
            for (String key : recordTypeMap.keySet()) {
                if (recordTypeMap.get(key).isActive() && !recordTypeMap.get(key).isMaster()) {
                    modules.add(new CommissionModule__c(
                        RecordTypeId = recordTypeMap.get(key).getRecordTypeId(),
                        CommissionDetail__c = cd.Id,
                        CurrencyIsoCode = cd.CurrencyIsoCode,
                        CompleteRate__c = new String[] {'Elements7', 'Reporting'}.contains(key) ? 1 : 0
                    ));
                }
            }
        }

        System.debug('modules.size=' + modules.size());
        insert modules;
    }
}