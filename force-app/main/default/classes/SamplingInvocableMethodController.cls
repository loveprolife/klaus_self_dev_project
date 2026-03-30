/*
 * @Author: WFC
 * @Date: 2025-03-13 09:17:36
 * @LastEditors: TJP
 * @LastEditTime: 2025-08-25 16:25:29
 * @Description: 出样检查 Sampling_Detail 和出样明细 Sample_Inspection 关联关系
 * @FilePath: \hisense005\force-app\main\default\classes\SamplingInvocableMethodController.cls
 */
public without sharing class SamplingInvocableMethodController{
    /**
     * @Param: reportIdList：巡店员日报id集合
     * @Return:
     * @Author: WFC
     * @Date: 2025-03-13 09:36:36
     * @Description: 巡店员日报状态变为 Submitted 的时候，触发方法
     */
    @InvocableMethod
    public static void relevanceSampling(List<String> reportIdList){
        System.debug('wwwwwww--reportIdList---' + reportIdList);
        // 查询 Sampling_Inspection__c 数据，Sampling_Detail__c 为空
        List<Sampling_Inspection__c> samplingInspectionList = [SELECT Id, Sample_Item__c, Shop__c, Product__c, Product__r.Product_Line__c, Placement_Status__c, Inspection_Report__c, Unplanned_Sample__c, Display_Type__c,CreatedBy.Name,Sales_Region__c
                                                               FROM Sampling_Inspection__c
                                                               WHERE Inspection_Report__c IN:reportIdList AND Product__c != NULL AND Shop__c != NULL];
        // 1：Sampling_Inspection__c 没有对应的 Sampling_Detail__c ,则生成 Sampling_Detail__c
        // 2：没有对应的 Store_Product_Line__c ,则生成 Store_Product_Line__c
        List<Sampling_Detail__c> samplingDetailAddList = new List<Sampling_Detail__c>();
        List<Store_Product_Line__c> storeProductLineAddList = new List<Store_Product_Line__c>();
        // Sampling_Inspection__c Id和对应的Sampling_Detail__c 外键组合map
        Map<String, String> samplingInspectionIdMap = new Map<String, String>();
        // Store_Product_Line__c map,key:门店+产品线
        Map<String, String> storeProductLineMap = new Map<String, String>();
        // KEY 对比出样检查使用的map,值：门店+产品+All
        Map<String, String> keyMap = new Map<String, String>();
        // 门店Id Set集合
        Set<String> shopIdSet = new Set<String>();
        System.debug('结果' + samplingInspectionList);
        List<Unplanned_Sample__c> usAddList = new List<Unplanned_Sample__c>();
        for (Sampling_Inspection__c samplingInspection : samplingInspectionList){
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
            // 未关联 Sampling_Detail__c 的数据
            String key = '';
            if (String.isNotBlank(samplingInspection.Display_Type__c) && samplingInspection.Display_Type__c != 'All'){
                key = samplingInspection.Shop__c + '-' + samplingInspection.Product__c + '-' + samplingInspection.Display_Type__c;
            } else{
                key = samplingInspection.Shop__c + '-' + samplingInspection.Product__c;
            }
            if (samplingInspection.Sample_Item__c == null){
                Sampling_Detail__c samplingDetail = new Sampling_Detail__c();
                samplingDetail.AutomaticallyGenerateSampleStandard__c = true;// 自动生成SampleStandard
                samplingDetail.Is_Add__c = '是';// 是否显示
                samplingDetail.Display_Status__c = samplingInspection.Placement_Status__c;// 展出状态
                samplingDetail.Unplanned_Sample__c = samplingInspection.Unplanned_Sample__c == 'No' ? '否' : '是';
                samplingDetail.Shop__c = samplingInspection.Shop__c;// 门店
                samplingDetail.Product__c = samplingInspection.Product__c;// 产品
                samplingDetail.ExternalID__c = key;// 外键
                System.debug('Key' + key);
                samplingDetail.Display_Type__c = samplingInspection.Display_Type__c;// 外键
                samplingDetailAddList.add(samplingDetail);
                samplingInspectionIdMap.put(samplingInspection.Id, samplingDetail.ExternalID__c);
            } else {
                System.debug('打印结果' + samplingInspection.Sample_Item__c + samplingInspection.Placement_Status__c);
                Sampling_Detail__c samplingDetail = new Sampling_Detail__c();
                samplingDetail.Id = samplingInspection.Sample_Item__c;
                samplingDetail.Display_Status__c = samplingInspection.Placement_Status__c;// 展出状态
                samplingDetail.Unplanned_Sample__c = samplingInspection.Unplanned_Sample__c == 'No' ? '否' : '是';
                samplingDetail.ExternalID__c = key;// 外键
                samplingDetailAddList.add(samplingDetail);
            }
            shopIdSet.add(samplingInspection.Shop__c);

            keyMap.put(key, key);
        }
        // 现有门店中 Store_Product_Line__c 集合
        List<Store_Product_Line__c> storeProductLineList = [SELECT Id, Store__c, Product_Line__c
                                                            FROM Store_Product_Line__c
                                                            WHERE Store__c IN:shopIdSet];
        for (Store_Product_Line__c storeProductLine : storeProductLineList){
            String key = storeProductLine.Store__c + storeProductLine.Product_Line__c;
            storeProductLineMap.put(key, key);
        }
        Savepoint sp = Database.setSavepoint();
        try{
            // 保存 Unplanned_Sample__c
            Database.upsert (usAddList, Unplanned_Sample__c.Fields.ExternalKey__c, true);
            // 保存 Sampling_Detail__c
            Database.upsert (samplingDetailAddList, Sampling_Detail__c.Fields.ExternalID__c, true);
            // Sampling_Detail__c key：外键,value: Id
            Map<String, String> samplingDetailMap = new Map<String, String>();
            for (Sampling_Detail__c sd : samplingDetailAddList){
                samplingDetailMap.put(sd.ExternalID__c, sd.Id);
            }
            // 给 Sampling_Inspection__c 关联的 Sampling_Detail__c 赋值并更新
            Map<String,Store_Product_Line__c> lines = new Map<String, Store_Product_Line__c>();
            Set<String> seenValues = new Set<String>();
            for (Sampling_Inspection__c samplingInspection : samplingInspectionList){
                if (samplingInspection.Sample_Item__c == null){
                    samplingInspection.Sample_Item__c = samplingDetailMap.get(samplingInspectionIdMap.get(samplingInspection.Id));
                }
                // 过滤 Store_Product_Line__c 是否已经存在
                String key = samplingInspection.Shop__c + samplingInspection.Product__r.Product_Line__c;
                
                // for(String key : originalMap.keySet()) {
                //     String value = originalMap.get(key);
                //     if(!seenValues.contains(value)) {
                //         seenValues.add(value);
                //         deduplicatedMap.put(key, value);
                //     }
                // }
                if (!storeProductLineMap.containsKey(key)){
                    if(!seenValues.isEmpty() && seenValues.contains(key)) {

                    } else {
                        seenValues.add(key);
                        Store_Product_Line__c storeProductLine = new Store_Product_Line__c();
                        storeProductLine.Store__c = samplingInspection.Shop__c;
                        storeProductLine.Product_Line__c = samplingInspection.Product__r.Product_Line__c;
                        storeProductLine.Entering_Status__c = 'Entered';
                        storeProductLineAddList.add(storeProductLine);
                    }
                }
            }
            Database.update (samplingInspectionList);
            Database.insert (storeProductLineAddList);

            // 删除计划外没有对应出样检查的 Sampling_Detail__c
            List<Sampling_Detail__c> delSamplingDetailList = new List<Sampling_Detail__c>();
            List<Sampling_Detail__c> allSamplingDetailList = [SELECT Id, Product__c, Display_Type__c, Shop__c
                                                              FROM Sampling_Detail__c
                                                              WHERE Shop__c IN:shopIdSet AND Unplanned_Sample__c = '是'];
            for (Sampling_Detail__c samplingDetail : allSamplingDetailList){
                String key = '';
                if (String.isNotBlank(samplingDetail.Display_Type__c) && samplingDetail.Display_Type__c != 'All'){
                    key = samplingDetail.Shop__c + '-' + samplingDetail.Product__c + '-' + samplingDetail.Display_Type__c;
                } else{
                    key = samplingDetail.Shop__c + '-' + samplingDetail.Product__c;
                }
                if (!keyMap.containsKey(key)){
                    delSamplingDetailList.add(samplingDetail);
                }
            }
            Database.delete (delSamplingDetailList);

        } catch (Exception e){
            Database.rollback(sp);
            System.debug('创建数据失败：' + e.getMessage() + e.getLineNumber());
            String errorMsg = e.getMessage() + e.getLineNumber();
            Utility.insertBatchLog('SamplingInvocableMethodController', errorMsg + '--' + JSON.serialize(reportIdList));
        }
    }

}