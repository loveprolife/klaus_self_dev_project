global class HistoricalSamplingSummaryBatch implements Database.Batchable<sObject> {
    /* 起始：拉所有明细 */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Sample_Item__c, Shop__c, Product__c, Product__r.Product_Line__c, Placement_Status__c, Inspection_Report__c, Unplanned_Sample__c, Display_Type__c,CreatedBy.Name,Sales_Region__c
            FROM Sampling_Inspection__c
            WHERE Inspection_Report__c != NULL AND Product__c != NULL AND Shop__c != NULL AND Inspection_State__c = 'Submitted'
        ]);
    }

    /* Max:100SQL;50000rows */
    public void execute(Database.BatchableContext bc, List<Sampling_Inspection__c> scope) {
        System.debug('数据量' + scope.size());
        
        List<Unplanned_Sample__c> usAddList = new List<Unplanned_Sample__c>();
        for (Sampling_Inspection__c samplingInspection : scope){
            // 进行 Unplanned_Sample__c 抽样汇总
            Unplanned_Sample__c us = new Unplanned_Sample__c(
                Inspection_Report__c = samplingInspection.Inspection_Report__c,
                Placement_Status__c = samplingInspection.Placement_Status__c,
                Product__c = samplingInspection.Product__c,
                Planned_Display__c = samplingInspection.Unplanned_Sample__c == 'No' ? 'Yes' : 'No',
                ExternalKey__c = samplingInspection.Inspection_Report__c + '-' + samplingInspection.Product__c +  '-' + samplingInspection.CreatedBy.Name,
                SBU__c = samplingInspection.Sales_Region__c
            );
            usAddList.add(us);
        }
        Savepoint sp = Database.setSavepoint();
        try{
            // 保存 Unplanned_Sample__c
            Database.upsert (usAddList, Unplanned_Sample__c.Fields.ExternalKey__c, true);
        } catch (Exception e){
            Database.rollback(sp);
            System.debug('创建数据失败：' + e.getMessage() + e.getLineNumber());
            String errorMsg = e.getMessage() + e.getLineNumber();
            Utility.insertBatchLog('HistoricalSamplingSummaryBatch', errorMsg + '--');
        }
    }


    public void finish(Database.BatchableContext bc) {
        // Utility.refreshReportCustom('AseanProductSummaryBatch');
    }



}