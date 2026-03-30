global class PhotoDownloadProcessBatch implements Database.Batchable<sObject>, Database.Stateful {
    global final String[] salesRegion;
    global final String shopId;
    global final Date dateStart;
    global final Date dateEnd;
    global final String channel;
    global final String walker;
    global final Integer batchSize;

    global PhotoDownloadProcessBatch(String[] salesRegion, String shopId, Date dateStart, Date dateEnd, String channel, String walker) {
        this.salesRegion = salesRegion;
        this.shopId = shopId;
        this.dateStart = dateStart != null ? dateStart : Date.today().addDays(-30);
        this.dateEnd = dateEnd != null ? dateEnd : Date.today().addDays(-1);
        this.channel = channel;
        this.walker = walker;
        this.batchSize = 1000; // 默认批次大小
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, InspectorDailyReport__c, InspectorDailyReport__r.Store__c, InspectorDailyReport__r.Sales_Region__c, InspectorDailyReport__r.Report_Date__c, CheckItem__r.Description__c, CheckItem__r.Item_Type__c, CheckItem__r.Project__c, Response__c, Result__c ' +

                       'FROM CheckResult__c ' +
                       'WHERE InspectorDailyReport__r.Sales_Region__c IN :salesRegion ' +
                       'AND InspectorDailyReport__r.Report_Date__c >= :dateStart ' +
                       'AND InspectorDailyReport__r.Report_Date__c <= :dateEnd ' +
                       (String.isEmpty(shopId) ? '' : 'AND InspectorDailyReport__r.Store__c = :shopId ') +
                       'AND InspectorDailyReport__r.Status__c = \'Submitted\' ' +
                       (String.isEmpty(channel) ? '' : 'AND InspectorDailyReport__r.Store__r.Channel_item__c = :channel ') +
                       (String.isEmpty(walker) ? '' : 'AND InspectorDailyReport__r.OwnerId = :walker ');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<CheckResult__c> checkResults = new List<CheckResult__c>();
        List<Sampling_Inspection__c> samplingInspections = new List<Sampling_Inspection__c>();

        for (sObject s : scope) {
            if (s instanceof CheckResult__c) {
                checkResults.add((CheckResult__c)s);
            } else if (s instanceof Sampling_Inspection__c) {
                samplingInspections.add((Sampling_Inspection__c)s);
            }
        }

        processCurrentBatch(checkResults, samplingInspections);
    }

    global void finish(Database.BatchableContext BC) {
        // List<Update_Data_Event__c> updateList = [SELECT Id, Last_Update_Time__c, Update_Status__c, Disabled__c
        //                                          FROM Update_Data_Event__c
        //                                          WHERE Batch_Class__c = 'PhotoDownloadProcessBatch' AND SBU__c IN :salesRegion FOR UPDATE];

        // if (!updateList.isEmpty()) {
        //     Update_Data_Event__c rc = updateList[0];
        //     rc.Last_Update_Time__c = System.now();
        //     rc.Update_Status__c = 'Update complete';
        //     update rc;
        // }
    }

    private void processCurrentBatch(List<CheckResult__c> checkResults, List<Sampling_Inspection__c> samplingInspections) {
        Set<Id> idSet = new Set<Id>();
        Map<Id, String> inspectionIdMap = new Map<Id, String>();
        Map<Id, String> itemTypeMap = new Map<Id, String>();
        Map<Id, String> descriptionMap = new Map<Id, String>();
        Map<Id, String> sbuMap = new Map<Id, String>();
        Map<Id, Date> dateMap = new Map<Id, Date>();
        Map<Id, String> storeMap = new Map<Id, String>();

        for (CheckResult__c checkResult : checkResults) {
            String itemType = String.isNotEmpty(checkResult.CheckItem__r.Item_Type__c) ? checkResult.CheckItem__r.Item_Type__c : checkResult.CheckItem__r.Project__c;
            String result = String.isEmpty(checkResult.Response__c) ? checkResult.Result__c : checkResult.Response__c;
            idSet.add(checkResult.Id);
            inspectionIdMap.put(checkResult.Id, checkResult.InspectorDailyReport__c);
            itemTypeMap.put(checkResult.Id, itemType);
            descriptionMap.put(checkResult.Id, checkResult.CheckItem__r.Description__c + ' ' + result);
            sbuMap.put(checkResult.Id, checkResult.InspectorDailyReport__r.Sales_Region__c);
            dateMap.put(checkResult.Id, checkResult.InspectorDailyReport__r.Report_Date__c);
            storeMap.put(checkResult.Id, checkResult.InspectorDailyReport__r.Store__c);
        }

        for (Sampling_Inspection__c inspection : samplingInspections) {
            String productName = inspection.Product__r.Name;
            String placementStatus = String.isNotEmpty(inspection.Placement_Status__c) && '展出'.equals(inspection.Placement_Status__c) ? 'Yes' : 'No';
            idSet.add(inspection.Id);
            inspectionIdMap.put(inspection.Id, inspection.Inspection_Report__c);
            itemTypeMap.put(inspection.Id, System.Label.Sample_Display);
            descriptionMap.put(inspection.Id, productName + ' ' + placementStatus);
            sbuMap.put(inspection.Id, inspection.Inspection_Report__r.Sales_Region__c);
            dateMap.put(inspection.Id, inspection.Inspection_Report__r.Report_Date__c);
            storeMap.put(inspection.Id, inspection.Shop__c);
        }

        // 查询 ContentDocumentLink
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :idSet
        ];

        // 构造 Inspection_Photo_Download__c 记录
        List<Inspection_Photo_Download__c> queryResults = new List<Inspection_Photo_Download__c>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            Inspection_Photo_Download__c queryResult = new Inspection_Photo_Download__c(
                DocumentId__c = cdl.ContentDocumentId,
                PhotoId__c = cdl.LinkedEntityId,
                InspectorDailyReport__c = inspectionIdMap.get(cdl.LinkedEntityId),
                Store__c = storeMap.get(cdl.LinkedEntityId),
                Inspection_Date__c = dateMap.get(cdl.LinkedEntityId),
                SBU__c = sbuMap.get(cdl.LinkedEntityId),
                Item_Type__c = itemTypeMap.get(cdl.LinkedEntityId),
                Description__c = descriptionMap.get(cdl.LinkedEntityId),
                ExternalKey__c = cdl.LinkedEntityId + '-' + cdl.ContentDocumentId
            );
            queryResults.add(queryResult);
        }
        upsert queryResults ExternalKey__c;
    }
}