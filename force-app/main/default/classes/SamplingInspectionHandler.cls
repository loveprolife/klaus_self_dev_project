public without sharing class SamplingInspectionHandler implements Triggers.Handler {
    public void handle() {
        
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

            List<String> keyList = new List<String>();

            for (Sampling_Inspection__c samplingInspection : (List<Sampling_Inspection__c>)Trigger.new) {
				// 出样明细为空
                if(samplingInspection.Sample_Item__c == null){
                    System.debug('wwww---' + samplingInspection.id);
                    // 门店的出样明细的外键
                    keyList.add(samplingInspection.Shop__c + '-' + samplingInspection.Product__c);
                }
			}
            System.debug('wwww---' + keyList);
            // 查询门店的出样明细
            List<Sampling_Detail__c> samplingDetailList = [SELECT id,ExternalID__c FROM Sampling_Detail__c WHERE ExternalID__c IN :keyList];
            Map<String, Id> samplingDetailMap = new Map<String, Id>();
            for (Sampling_Detail__c sd : samplingDetailList) {
                samplingDetailMap.put(sd.ExternalID__c, sd.Id);
            }
            System.debug('wwww---' + samplingDetailMap);

            for (Sampling_Inspection__c samplingInspection : (List<Sampling_Inspection__c>)Trigger.new) {
				// 出样明细为空
                if(samplingInspection.Sample_Item__c == null){
                    samplingInspection.Sample_Item__c = samplingDetailMap.get(samplingInspection.Shop__c + '-' + samplingInspection.Product__c);
                }
			}
        }
            
    }    
}