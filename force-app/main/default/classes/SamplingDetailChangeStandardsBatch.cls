/*
 * @Author: WFC
 * @Date: 2023-03-14 16:33:35
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-16 17:55:02
 * @Description: 批量修改计划外特殊出样标准的出样明细
 * @Execution code：SamplingDetailChangeStandardsBatch ss  = new SamplingDetailChangeStandardsBatch('a1o0T0000007Q6HQAU'); Database.executeBatch(ss, 200);
 * @FilePath: \Hitest_2022\force-app\main\default\classes\SamplingDetailChangeStandardsBatch.cls
 */
global class SamplingDetailChangeStandardsBatch implements Database.Batchable<sObject> {
    public String query;
    public String samplingStandardId;

    global SamplingDetailChangeStandardsBatch(String samplingStandardId) {
        this.samplingStandardId  = samplingStandardId;
        this.query = 'SELECT id,CreatedDate, CreatedBy.name,Product__c, Product__r.name, Shop_Level__c ,Shop__c, Shop__r.Shop_Level__c, Shop__r.Account__c, Shop__r.Account__r.name, Sampling_Standard__c ' + 
        ' FROM Sampling_Detail__c WHERE Sampling_Standard__c =: samplingStandardId';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sampling_Detail__c> samplingDetailList) {
        // 客户 + 产品
        Set<String> accountProductSet = new Set<String>();
        // MAP
        Map<String, List<Sampling_Detail__c>> samplingDetailmap = new Map<String, List<Sampling_Detail__c>>();
        // update Data
        List<Sampling_Detail__c> updateData = new List<Sampling_Detail__c>();
        for (Sampling_Detail__c samplingDetail : samplingDetailList) {
            String key = samplingDetail.Shop__r.Account__c + '-' + samplingDetail.Product__c;
            
            accountProductSet.add(key);

            if(samplingDetailmap.containsKey(key)){
                samplingDetailmap.get(key).add(samplingDetail);
            }else{
                samplingDetailmap.put(key,new List<Sampling_Detail__c>{samplingDetail});
            }
        }
        System.debug('accountProductSet-----' + accountProductSet);
        List<Sampling_Standard__c> samplingStandardList = [SELECT id,Level__c,Product__c,ExternalID__c,Sampling_Mapping__r.Level__c, Sampling_Mapping__r.Shop_Level__c FROM Sampling_Standard__c WHERE ExternalID__c IN :accountProductSet];
        for (Sampling_Standard__c samplingStandard : samplingStandardList) {
            System.debug('samplingStandard-----' + samplingStandard);
            System.debug('samplingStandard.Sampling_Mapping__r-2-----' + samplingStandard.Sampling_Mapping__r);
            if(String.isBlank(samplingStandard.Sampling_Mapping__r.Shop_Level__c) ){
                continue;
            }
            List<Sampling_Detail__c> samplingDetail = samplingDetailmap.get(samplingStandard.ExternalID__c);
            List<String> levelList = samplingStandard.Sampling_Mapping__r.Shop_Level__c.split(';');
            for(Sampling_Detail__c sd : samplingDetail){
                if(!levelList.contains(sd.Shop_Level__c)){
                    continue;
                }
                sd.Sampling_Standard__c = samplingStandard.id;
                updateData.add(sd);
            }
        }
        Database.update(updateData);

    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}