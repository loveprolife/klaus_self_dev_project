/*
 * @Author: WFC
 * @Date: 2024-06-03 20:46:50
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-03 22:26:31
 * @Description: 刷新Sampling_Detail__c中的缩略图 Database.executeBatch(new SamplingDetailImgBatch());
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\SamplingDetailImgBatch.cls
 */
global class SamplingDetailImgBatch implements Database.Batchable<sObject>{
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        query = 'SELECT Id from Sampling_Detail__c WHERE ContentDocumentId__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Sampling_Detail__c> samplingDetailList){
        Map<String, Sampling_Inspection__c> siMap = new Map<String, Sampling_Inspection__c>();
        Set<String> sdIdSet = new Set<String>();
        for (Sampling_Detail__c sd : samplingDetailList){
            sdIdSet.add(sd.Id);
        }
        // 查询相关的出样检查
        List<Sampling_Inspection__c> siLisst = [SELECT Id, Inspection_Date__c, Shop__c, Sample_Item__c, OwnerId
                                                FROM Sampling_Inspection__c
                                                WHERE Inspection_Shop_Task__r.Daily_Inspection_Report__r.Status__c = 'Submitted' AND Sample_Item__c IN:sdIdSet];
        for (Sampling_Inspection__c si : siLisst){
            if (siMap.containsKey(si.Sample_Item__c)){
                Sampling_Inspection__c inSi = siMap.get(si.Sample_Item__c);
                if (inSi.Inspection_Date__c < si.Inspection_Date__c){
                    siMap.put(si.Sample_Item__c, si);
                }
            } else{
                siMap.put(si.Sample_Item__c, si);
            }
        }
        // 查询出样检查对应的文件
        if (siMap.keySet().size() > 0){
            List<Sampling_Detail__c> updateList = new List<Sampling_Detail__c>();
            Map<String, ContentVersion> cvMap = new Map<String, ContentVersion>();
            Set<String> siIdSet = new Set<String>();
            for (Sampling_Inspection__c si : siMap.values()){
                siIdSet.add(si.Id);
            }
            List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.FileType, LinkedEntityId
                                                           FROM ContentDocumentLink
                                                           WHERE LinkedEntityId = :siIdSet
                                                           WITH SECURITY_ENFORCED];
            for (ContentDocumentLink cdl : attachedDocuments){
                ContentVersion cv = [SELECT Id, ContentBodyId, ContentDocumentId
                                     FROM ContentVersion
                                     WHERE ContentDocumentId = :cdl.ContentDocumentId AND IsLatest = true
                                     ORDER BY VersionNumber DESC
                                     LIMIT 1];
                cvMap.put(cdl.LinkedEntityId, cv);
            }
            for (String sampleItem : siMap.keySet()){
                Sampling_Inspection__c si = siMap.get(sampleItem);
                Sampling_Detail__c sd = new Sampling_Detail__c();
                sd.Id = sampleItem;
                if (cvMap.containsKey(si.Id)){
                    sd.ContentDocumentId__c = cvMap.get(si.Id).ContentDocumentId;
                    sd.CoverImgVersionId__c = cvMap.get(si.Id).Id;
                    sd.CoverImgContentBodyId__c = cvMap.get(si.Id).ContentBodyId;
                    sd.Sampling_Inspection_User__c = si.OwnerId;
                    sd.Sampling_Inspection_Date__c = si.Inspection_Date__c;
                    updateList.add(sd);
                }

            }
            update updateList;
        }
    }

    global void finish(Database.BatchableContext bc){
    }

}