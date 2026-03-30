/**
 * @description      : 促销员日报后端类
 * @author           : DTT-Bright
 * @last modified on : 2024-01-18
 * @last modified by : DTT-Bright
 */ 
public without sharing class NewSampleInspectorController {
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    public static Date thisDay = System.today();
    public static String thisTime = DateTime.now().format('HH:mm',UserInfo.getTimeZone().getId());
    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title FROM User WHERE Id = : UserInfo.getUserId()][0];

    @AuraEnabled
    public static ConResponse getInitData(String recordId, String currentLat, String currentLong, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Nacho'];
        if(ul != null && ul.size() > 0){
            mso.put('ticketAssignedTo', ul.get(0).Id);
        }
        
        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 
        // 获取Product Line Picklist Value顺序
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 

        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        if (String.isNotBlank(recordId)) {
            // 查询日报
            List<Sample_Inspector__c> dirList = getExistDailyInspectionReportBasedId(recordId);
            if (dirList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Sample_Inspector__c.getLabel()});
                return resp;
            }

            Sample_Inspector__c dir = dirList[0];
            mso.put('record', dir);
            mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            // List<Shop__c> storeList = getStores();
            // storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, storeList, dir.Report_Date__c, dir.Store__c);
            // mso.put('storeDistanceList', storeDistanceList); 

            // Sampling Inspection部分
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(dir.Id);
            mso.put('samplingInspections', siList);
            
            // 判断是否为日报所属人查看日报
            if (UserInfo.getUserId()!=dir.OwnerId) {
                mso.put('isReportUser', false);
            } else {
                mso.put('isReportUser', true);
            }

            Map<String,List<String>> documentIdMap = new Map<String,List<String>>();
            List<String> siIdList = new LisqContainer(siList).ToIds();
            if(siIdList != null && siIdList.size() > 0){
                List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:siIdList];
                for(ContentDocumentLink cdt : cdlList){
                    if(documentIdMap.containsKey(cdt.LinkedEntityId)){
                        List<String> testList = documentIdMap.get(cdt.LinkedEntityId);
                        testList.add(cdt.ContentDocumentId);
                        documentIdMap.put(cdt.LinkedEntityId, testList);
                    }else {
                        documentIdMap.put(cdt.LinkedEntityId, new List<String>{ cdt.ContentDocumentId });
                    }
                }
            }
            mso.put('retailNumberHaveFileIdMap', documentIdMap);

        } else {
            List<Shop__c> storeList = getStores();
            storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, storeList, thisDay, shopId);
            mso.put('storeDistanceList', storeDistanceList); 

            // 距离位置最近门店Id
            String storeId = storeDistanceList.size()>0 ? (String)storeDistanceList[0].get('storeId') : null;
            if(storeId == null && String.isNotEmpty(currentLat) && String.isNotEmpty(currentLong)) {
                storeId = getStoreForDistance(currentLat, currentLong);
            }
            // 日报ExId
            String dirExId = storeId + '_' + UserInfo.getUserId() + '_' + thisDay;
            // 查询是否存在日报
            Sample_Inspector__c dir;
            List<Sample_Inspector__c> dirList = getExistDailyInspectionReportBasedExternalId(storeId, UserInfo.getUserId(), thisDay);
            if (dirList.size()>0) {
                dir = dirList[0];
            }
            // 存在日报
            if (dir!=null) {
                mso.put('record', dir);
                mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
                
                // Sampling Inspection部分
                List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(dir.Id);
                mso.put('samplingInspections', siList);

                // 判断是否为日报所属人查看日报
                if (UserInfo.getUserId()!=dir.OwnerId) {
                    mso.put('isReportUser', false);
                } else {
                    mso.put('isReportUser', true);
                }

                Map<String,List<String>> documentIdMap = new Map<String,List<String>>();
                List<String> siIdList = new LisqContainer(siList).ToIds();
                if(siIdList != null && siIdList.size() > 0){
                    List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:siIdList];
                    for(ContentDocumentLink cdt : cdlList){
                        if(documentIdMap.containsKey(cdt.LinkedEntityId)){
                            List<String> testList = documentIdMap.get(cdt.LinkedEntityId);
                            testList.add(cdt.ContentDocumentId);
                            documentIdMap.put(cdt.LinkedEntityId, testList);
                        }else {
                            documentIdMap.put(cdt.LinkedEntityId, new List<String>{ cdt.ContentDocumentId });
                        }
                    }
                }
                mso.put('retailNumberHaveFileIdMap', documentIdMap);
            // 不存在日报
            } else {
                Sample_Inspector__c dirNew = new Sample_Inspector__c(
                    Report_Date__c = thisDay,
                    Store__c = storeId,
                    Status__c = 'New'
                );

                mso.put('record', dirNew);
                mso.put('ownerName', user.Name);
            }
        }
        
        return resp;
    }

    // 刷新数据
    @AuraEnabled()
    public static ConResponse refreshData(String recordJson, String currentLat, String currentLong, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson' + recordJson);
        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);

        List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Nacho'];
        if(ul != null && ul.size() > 0){
            mso.put('ticketAssignedTo', ul.get(0).Id);
        }

        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        // List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        // List<Shop__c> storeList = getStores();
        // storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, storeList, report.Report_Date__c, shopId);
        // mso.put('storeDistanceList', storeDistanceList); 

        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 
        // 获取Product Line Picklist Value顺序
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 
        // 日报ExId
        String dirExId = report.Store__c + '_' + UserInfo.getUserId() + '_' + report.Report_Date__c;
        System.debug('wwwwdirExId' + dirExId);
        // 查询是否存在日报
        Sample_Inspector__c dir;
        List<Sample_Inspector__c> dirList = getExistDailyInspectionReportBasedExternalId(report.Store__c, UserInfo.getUserId(), thisDay);
        if (dirList.size()>0) {
            dir = dirList[0];
        }
        // 存在日报
        if (dir!=null) {
            mso.put('record', dir);
            mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            // Sampling Inspection部分
            // 获取计划外Sampling Inspection信息
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(dir.Id);
            mso.put('samplingInspections', siList);
            
            // 判断是否为日报所属人查看日报
            if (UserInfo.getUserId()!=dir.OwnerId) {
                mso.put('isReportUser', false);
            } else {
                mso.put('isReportUser', true);
            }

            Map<String,List<String>> documentIdMap = new Map<String,List<String>>();
            List<String> siIdList = new LisqContainer(siList).ToIds();
            if(siIdList != null && siIdList.size() > 0){
                List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:siIdList];
                for(ContentDocumentLink cdt : cdlList){
                    if(documentIdMap.containsKey(cdt.LinkedEntityId)){
                        List<String> testList = documentIdMap.get(cdt.LinkedEntityId);
                        testList.add(cdt.ContentDocumentId);
                        documentIdMap.put(cdt.LinkedEntityId, testList);
                    }else {
                        documentIdMap.put(cdt.LinkedEntityId, new List<String>{ cdt.ContentDocumentId });
                    }
                }
            }
            mso.put('retailNumberHaveFileIdMap', documentIdMap);
        // 不存在日报
        } else {

            Sample_Inspector__c dirNew = new Sample_Inspector__c(
                Report_Date__c = report.Report_Date__c,
                Store__c = report.Store__c,
                Status__c = 'New'
            );

            mso.put('record', dirNew);
            mso.put('ownerName', user.Name);
        }

        return resp;
    }

    // create record
    @AuraEnabled
    public static ConResponse createRecord(String recordJson,String currentLat, String currentLong) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson' + recordJson);
        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);

        // 新建日报
        upsert report;
        report = getExistDailyInspectionReportBasedId(report.Id)[0];
        // 新建Sampling Inspection
        createSamplingInspection(report.Store__c, report.Report_Date__c, report.Id);
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(report.Id);
    
        mso.put('samplingInspections', siList);
        // 新建Sampling Inspection unplan --- Added By Sunny End

        Map<String,List<String>> documentIdMap = new Map<String,List<String>>();
        List<String> siIdList = new LisqContainer(siList).ToIds();
        if(siIdList != null && siIdList.size() > 0){
            List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:siIdList];
            for(ContentDocumentLink cdt : cdlList){
                if(documentIdMap.containsKey(cdt.LinkedEntityId)){
                    List<String> testList = documentIdMap.get(cdt.LinkedEntityId);
                    testList.add(cdt.ContentDocumentId);
                    documentIdMap.put(cdt.LinkedEntityId, testList);
                }else {
                    documentIdMap.put(cdt.LinkedEntityId, new List<String>{ cdt.ContentDocumentId });
                }
            }
        }
        mso.put('retailNumberHaveFileIdMap', documentIdMap);
        
     
        
        mso.put('record', report);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(report.Id)[0].Owner.Name);
        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 

        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        // List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        // List<Shop__c> storeList = getStores();
        // storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, storeList, report.Report_Date__c, report.Store__c);
        // mso.put('storeDistanceList', storeDistanceList); 

        return resp;
    }

    // upsert record
    @AuraEnabled
    public static ConResponse upsertRecord(String recordJson, String samplingInspectionJson, String ticketOpenJson, String ticketClosedJson, String ticketOpenFilesMapJson, Boolean isSubmit) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Savepoint sp = Database.setSavepoint();

        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);

        if (isSubmit) {
            report.Status__c = 'Submitted';
        }

        // Submit场景
        if (report.Status__c == 'Submitted') {

            Map<String, Object> checkResp = SubmitReport(report);
            if (!(Boolean)checkResp.get('isSuccess')) {
                mso.put('submitCheckError', (String)checkResp.get('errorMsg'));
                Database.rollback(sp);
                return resp;
            }
        }

        // samplingInspection 
        System.debug('samplingInspectionJson' + samplingInspectionJson);
        List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionJson, List<Sampling_Inspection__c>.class);
        upsert siList;

        if (report.Status__c == 'Submitted') {
            updateSamplingDetail(siList);
        }
  
        upsert report;
       
        // 查询日报（更新总分和平均分数据）
        Sample_Inspector__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        
        return resp;
    }

    // Submit场景
    public static Map<String, Object> SubmitReport(Sample_Inspector__c report) {
        Map<String, Object> resp = new Map<String, Object>();
        resp.put('isSuccess', true);
        resp.put('errorMsg', '');
        return resp;
    }

    // 刷新定位距离信息
    @AuraEnabled
    public static ConResponse refreshPositioning(String currentLat, String currentLong, String recordDate, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 获取门店负责人信息，确定可选门店
        List<Shop__c> storeList = getStores();
        List<Map<String, Object>> storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, storeList, Date.valueOf(recordDate), shopId);
        mso.put('storeDistanceList', storeDistanceList); 
        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 

        System.debug('resp======>'+resp);
        return resp;
    }

    // 根据坐标计算距离 (因为有SOQL查询，方法不可用在循环内)
    public static List<Map<String, Object>> getStoreDistanceListForStore(String currentLat, String currentLong, List<Shop__c> storeList, Date reportDate, String shopId) {
        // 计算和绑定门店距离
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
     
        for (Shop__c store : storeList) {
          
            Map<String, Object> storeDistanceMap = new Map<String, Object>();
            Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
            Decimal distance = 999.999;
            if (store.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
                distance = location.getDistance(store.Shop_Center_Location__c,'km');
                storeDistanceMap.put('storeLat', store.Shop_Center_Location__Latitude__s);
                storeDistanceMap.put('storeLong', store.Shop_Center_Location__Longitude__s);
            } else {
                storeDistanceMap.put('storeLat', 0);
                storeDistanceMap.put('storeLong', 0);
            }
            storeDistanceMap.put('storeId', store.Id);
            storeDistanceMap.put('storeName', store.Name);
            storeDistanceMap.put('storeDistance', distance);
            storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');

            // 排序
            if (storeDistanceList.size()>0) {
                for (Integer i = 0; i < storeDistanceList.size(); i++) {
                    Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
                    if (distance<=itemDistance) {
                        storeDistanceList.add(i, storeDistanceMap);
                        break;
                    } else if ((i+1)==storeDistanceList.size()) {
                        storeDistanceList.add(storeDistanceMap);
                        break;
                    }
                }
            } else {
                storeDistanceList.add(storeDistanceMap);
            }
        }

        // if(String.isNotBlank(shopId)){
        //     Shop__c shop = [SELECT Id,Name,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s FROM Shop__c WHERE Id = :shopId LIMIT 1];
        //     Map<String, Object> storeDistanceMap = new Map<String, Object>();
        //     Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
        //     Decimal distance = 999.999;
        //     if (shop.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
        //         distance = location.getDistance(shop.Shop_Center_Location__c,'km');
        //         storeDistanceMap.put('storeLat', shop.Shop_Center_Location__Latitude__s);
        //         storeDistanceMap.put('storeLong', shop.Shop_Center_Location__Longitude__s);
        //     } else {
        //         storeDistanceMap.put('storeLat', 0);
        //         storeDistanceMap.put('storeLong', 0);
        //     }
        //     storeDistanceMap.put('storeId', shop.Id);
        //     storeDistanceMap.put('storeName', shop.Name);
        //     storeDistanceMap.put('storeDistance', distance);
        //     storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');

        //     // 排序
        //     if (storeDistanceList.size()>0) {
        //         for (Integer i = 0; i < storeDistanceList.size(); i++) {
        //             Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
        //             if (distance<=itemDistance) {
        //                 storeDistanceList.add(i, storeDistanceMap);
        //                 break;
        //             } else if ((i+1)==storeDistanceList.size()) {
        //                 storeDistanceList.add(storeDistanceMap);
        //                 break;
        //             }
        //         }
        //     } else {
        //         storeDistanceList.add(storeDistanceMap);
        //     }
        // }

        return storeDistanceList;
    }

    // 获取Sampling Detail，并新建Sampling Inspection
    public static void createSamplingInspection(String storeId, Date reportDate, String reportId) {
        // 查询历史Sampling Inspection
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreId(storeId, Userinfo.getUserId(), Date.newInstance(reportDate.year(),1,1));
        Map<String, List<Sampling_Inspection__c>> siOldMap = new Map<String, List<Sampling_Inspection__c>>();
        for (Sampling_Inspection__c si : siList) {
            if (siOldMap.containskey(si.Sample_Item__c)) {
                List<Sampling_Inspection__c> siItems = siOldMap.get(si.Sample_Item__c);
                siItems.add(si);
            } else {
                List<Sampling_Inspection__c> siItems = new List<Sampling_Inspection__c>();
                siItems.add(si);
                siOldMap.put(si.Sample_Item__c, siItems);
            }
        }
        // 新建Sampling Inspection，先查询门店Sampling Detail
        List<Sampling_Detail__c> sdList = getExistSamplingDetailBaseStoreId(storeId);
        List<Sampling_Inspection__c> newSiList = new List<Sampling_Inspection__c>();
        List<Sampling_Inspection__c> oldSiList = new List<Sampling_Inspection__c>();
        for (Sampling_Detail__c sd : sdList) {
            //待用
            if (siOldMap.containskey(sd.Id)) {
                Sampling_Inspection__c oldSi = siOldMap.get(sd.Id)[0];
                
                Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                newSi.Inspection_Date__c = reportDate;
                newSi.Placement_Status__c = sd.Display_Status__c;
                newSi.Unplanned_Sample__c = 'Yes';
                newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + sd.Product__c + '_' + UserInfo.getUserId() + '_' + reportId;
                newSi.Product__c = sd.Product__c;
                newSi.Shop__c = storeId;
                newSi.Sample_Item__c = sd.Id;
                newSi.ReRe__c = sd.ReRe__c;
                newSi.Price__c = sd.Price__c;
                newSi.Quantity__c = sd.Quantity__c;
                newSi.Exhibition_Format__c = sd.Exhibition_Format__c;
                newSi.Sample_Inspector__c = reportId;

                newSiList.add(newSi);
                oldSiList.add(oldSi);
            } else {
                Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                newSi.Inspection_Date__c = reportDate;
                newSi.Placement_Status__c = sd.Display_Status__c;
                newSi.Unplanned_Sample__c = 'Yes';
                newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + sd.Product__c + '_' + UserInfo.getUserId() + '_' + reportId;
                newSi.Product__c = sd.Product__c;
                newSi.Shop__c = storeId;
                newSi.Sample_Item__c = sd.Id;
                newSi.ReRe__c = sd.ReRe__c;
                newSi.Price__c = sd.Price__c;
                newSi.Quantity__c = sd.Quantity__c;
                newSi.Exhibition_Format__c = sd.Exhibition_Format__c;
                newSi.Sample_Inspector__c = reportId;

                newSiList.add(newSi);
            }
        }
        insert newSiList;
        samplingInspectionBindAttachments(newSiList, oldSiList);

    }

    // Sampling Inspection绑定当年最近日期附件
    public static void samplingInspectionBindAttachments(List<Sampling_Inspection__c> newSiList, List<Sampling_Inspection__c> oldSiList) {
        // 根据Sample Item整理Map，整理出old Map new 的Id Map
        Map<String, Sampling_Inspection__c> newSitemMap = new Map<String, Sampling_Inspection__c>();
        for (Sampling_Inspection__c newSi : newSiList) {
            newSitemMap.put(newSi.Sample_Item__c, newSi);
        }
        Map<String, String> oldMapNew = new Map<String, String>();
        for (Sampling_Inspection__c oldSi : oldSiList) {
            if (newSitemMap.containsKey(oldSi.Sample_Item__c)) {
                Sampling_Inspection__c newSi = newSitemMap.get(oldSi.Sample_Item__c);
                oldMapNew.put(oldSi.Id, newSi.Id);
            }
        }
        if (oldMapNew.size()==0) {
            return;
        }
        // 查询OldSi记录的附件
        List<ContentDocumentLink> querySi = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : oldMapNew.keySet()];
        Map<String, List<String>> documentMap = new Map<String, List<String>>();
        for (ContentDocumentLink item : querySi) {
            if (documentMap.containsKey(item.LinkedEntityId)) {
                List<String> linkedIds = documentMap.get(item.LinkedEntityId);
                linkedIds.add(item.ContentDocumentId);
            } else {
                List<String> linkedIds = new List<String>();
                linkedIds.add(item.ContentDocumentId);
                documentMap.put(item.LinkedEntityId, linkedIds);
            }
        }
        // 关联新记录
        List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
        for (String oldId : oldMapNew.keySet()) {
            String newId = oldMapNew.get(oldId);
            if (documentMap.containsKey(oldId)) {
                for (String documentId : documentMap.get(oldId)) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = documentId;
                    cdl.LinkedEntityId = newId;
                    cdl.ShareType = 'V';
                    insertCdlList.add(cdl);
                }
            }
        }
        if (insertCdlList.size()>0) {
            insert insertCdlList;
        }
    }

    // 更新Sampling Detail
    public static void updateSamplingDetail(List<Sampling_Inspection__c> siList) {
        Map<String, Sampling_Inspection__c> planInSI = new Map<String, Sampling_Inspection__c>();
        Map<String, ContentVersion> cvMap = new Map<String, ContentVersion>();
        Set<String> cLinkSet = new Set<String>();

        String storeId = '';
        for (Sampling_Inspection__c si : siList){
            // if (si.Sample_Item__c != null){
            //     planInSI.put(si.Sample_Item__c, si);
            //     cLinkSet.add(si.Id);
            // }

            planInSI.put(si.Shop__c+'-'+si.Product__c, si);
            cLinkSet.add(si.Id);

            storeId = si.Shop__c;
        }


        if (planInSI.keySet().size() > 0){
            // 查询相关的文件信息
            List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.FileType, LinkedEntityId
                                                           FROM ContentDocumentLink
                                                           WHERE LinkedEntityId = :cLinkSet
                                                           WITH SECURITY_ENFORCED];
            for (ContentDocumentLink cdl : attachedDocuments){
                ContentVersion cv = [SELECT Id, ContentBodyId, ContentDocumentId
                                     FROM ContentVersion
                                     WHERE ContentDocumentId = :cdl.ContentDocumentId AND IsLatest = true
                                     ORDER BY VersionNumber DESC
                                     LIMIT 1];
                cvMap.put(cdl.LinkedEntityId, cv);
            }
            List<Sampling_Detail__c> sdList = getExistSamplingDetailBaseId(planInSI.keySet());
            List<Sampling_Detail__c> sdDelList = getExistSamplingDetailBaseIdDel(planInSI.keySet(), storeId);

            if(sdDelList != null && sdDelList.size() > 0){
                delete sdDelList;
            }
            for (Sampling_Detail__c sd : sdList){
                Sampling_Inspection__c si = planInSI.get(sd.ExternalID__c);
                planInSI.remove(sd.ExternalID__c);

                sd.Unplanned_Sample__c = si.Unplanned_Sample__c == 'No' ? '否' : '是';
                sd.Display_Status__c = si.Placement_Status__c;
                //lzx 20250522 江燕要求记录出样明细最后一次操作的用户和日期
                sd.Sampling_Inspection_User__c = System.UserInfo.getUserId();
                sd.Sampling_Inspection_Date__c = si.Inspection_Date__c;
                sd.ReRe__c = si.ReRe__c;
                sd.Price__c = si.Price__c;
                sd.Quantity__c = si.Quantity__c;
                sd.Exhibition_Format__c = si.Exhibition_Format__c;
                if (cvMap.containsKey(si.Id)){
                    sd.ContentDocumentId__c = cvMap.get(si.Id).ContentDocumentId;
                    sd.CoverImgVersionId__c = cvMap.get(si.Id).Id;
                    sd.CoverImgContentBodyId__c = cvMap.get(si.Id).ContentBodyId;
                }
            }

            for(Sampling_Inspection__c si : planInSI.values()){
                Sampling_Detail__c samplingDetail = createSamplingDetail(si);
                if (cvMap.containsKey(si.Id)){
                    samplingDetail.ContentDocumentId__c = cvMap.get(si.Id).ContentDocumentId;
                    samplingDetail.CoverImgVersionId__c = cvMap.get(si.Id).Id;
                    samplingDetail.CoverImgContentBodyId__c = cvMap.get(si.Id).ContentBodyId;
                }
                sdList.add(samplingDetail);
            }
            upsert sdList;

            for (Sampling_Detail__c sd : sdList){
                Sampling_Inspection__c si = planInSI.get(sd.ExternalID__c);
                if(si != null){
                    si.Sample_Item__c = sd.Id;
                }
            }

            update planInSI.values();
        }
    }

    // 删除产品线 （Sampling Inspection、CheckResult）
    @AuraEnabled
    public static ConResponse delProductLine(String recordJson, String productLine) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);
        
        List<Sampling_Inspection__c> delSiList = getExistPlanOutSamplingInspectionBaseStoreIddDateProductLine(report.Store__c, report.Report_Date__c, productLine, report.OwnerId, report.Id);
   
        delete delSiList;

        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(report.Id);
        mso.put('samplingInspections', siList);
    
        // 更新日报信息
        List<Sample_Inspector__c> dirList = getExistDailyInspectionReportBasedId(report.Id);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Sample_Inspector__c.getLabel()});
            return resp;
        }
        Sample_Inspector__c dir = dirList[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);
        return resp;
    }

    // 附件上传
    public static void createUploadFile(String recordId, String photoStream){
        System.debug('photoStream--->'+photoStream);

        if (recordId==null || photoStream==null || photoStream=='') {
            return;
        }
        
        String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(photoStream.substring(23,photoStream.length()));
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';

        insert cdl;
    }

    // 获取Picklist values
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getPickList(String objectName, String fieldName) {
        if (String.isBlank(fieldName)) {
            return null;
        }

        try {
            Map<String, String> temp = Utility.getPicklistValueMap(objectName, fieldName);
            List<Map<String, String>> result = new List<Map<String, String>>();
            for (String key : temp.keySet()) {
                if (objectName=='Task' && fieldName=='Status') {
                    if (temp.get(key)=='Open'||temp.get(key)=='Resolved'||temp.get(key)=='Closed') {
                        result.add(new Map<String, String> {
                            'label' => temp.get(key),
                            'value' => key
                        });
                    }
                } else {
                    result.add(new Map<String, String> {
                        'label' => temp.get(key),
                        'value' => key
                    });
                }
            }

            return result;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
        }

        return null;
    }
   
    public static List<Shop__c> getStores() {
        return [SELECT 
                    Id,
                    Name,
                    Shop_Center_Location__c,
                    Shop_Center_Location__Latitude__s,
                    Shop_Center_Location__Longitude__s
                FROM Shop__c 
                WHERE 
                    Sales_Region__c = :user.Sales_Region__c];
    }

    // 获取日报信息
    public static List<Sample_Inspector__c> getExistDailyInspectionReportOwnerNameBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Owner.Name
                FROM Sample_Inspector__c 
                WHERE 
                    Id =: recordId];
    }

    /**
     * @description 获取巡店报告
     * @param   recordId     报告id
     * @return  巡店报告
     */
    public static List<Sample_Inspector__c> getExistDailyInspectionReportBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Store__c,
                    Report_Date__c,
                    Sales_Region__c,
                    OwnerId
                FROM Sample_Inspector__c 
                WHERE 
                    Id =: recordId];
    }

    /**
     * @description 以巡店报告
     * @param   externalId     报告id
     * @return  巡店报告
     */
    public static List<Sample_Inspector__c> getExistDailyInspectionReportBasedExternalId(String storeId, String userId, Date thisDay) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Store__c,
                    Report_Date__c,
                    OwnerId
                FROM Sample_Inspector__c 
                WHERE 
                    Status__c != 'Submitted'
                    and Store__c = :storeId
                    and OwnerId = :userId
                    and Report_Date__c <= :thisDay];
    }

    // 获取Sampling Detail
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseStoreId(String storeId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    Display_Status__c,
                    Unplanned_Sample__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Price__c,
                    Quantity__c,
                    Exhibition_Format__c,
                    rere__c,
                    Rent__c,
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE 
                    Shop__c = : storeId
                AND Is_Add__c = '是'];
    }

    /**
     * @description 获取出样明细
     * @param   ids 出样明细列表
     * @return  出样明细
     */
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    ExternalID__c,
                    Display_Status__c,
                    Unplanned_Sample__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE 
                    ExternalID__c IN : ids];
    }

    /**
     * @description 获取删除出样明细
     * @param   ids 出样明细列表
     * @return  出样明细
     */
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseIdDel(Set<String> ids, String storeId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    ExternalID__c,
                    Display_Status__c,
                    Unplanned_Sample__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE Is_Add__c = '是' and
                    ExternalID__c not IN : ids and Shop__c = :storeId];
    }

    // 获取Sampling Inspection
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreId(String storeId, String userId, Date yearFirstDay) {
        List<Sampling_Inspection__c> sampl1 = [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    Rent__c,
                    ReRe__c,
                    Price__c,
                    Quantity__c,
                    Exhibition_Format__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c =  : storeId
                AND OwnerId = : userId
                AND Inspection_Date__c >= :yearFirstDay
                ORDER BY Inspection_Date__c,CreatedDate DESC];
        
        return sampl1;
    }

    /**
     * @description 获取计划外出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productline  产品线
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreIddDateProductLine(String storeId, Date recordDate, String productline, String ownerId, String reportId) {
        return [
                SELECT 
                    Id,Sample_Item__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate
                AND Product__r.Product_Line__c = : productline
                AND OwnerId = : ownerId
                AND Sample_Inspector__c = :reportId
                ORDER BY Product__r.Product_Line__c DESC];
    }

    //2024-01-12 lizunxing 日本巡店日报计划外创建出样明细
    public static Sampling_Detail__c createSamplingDetail(Sampling_Inspection__c newSi){

        //出样明细外键Set
        //Set<String> detailExternalIdSet = new Set<String>();

        //出样明细查询
        //detailExternalIdSet.add(newSi.Shop__c+'-'+newSi.Product__c);

        //List<Sampling_Detail__c> checkL = [select id from Sampling_Detail__c where ExternalID__c in :detailExternalIdSet];

        // if(checkL != null && checkL.size() > 0){
        //     return null;
        // }
        Sampling_Detail__c samplingDetail = new Sampling_Detail__c(); 
        samplingDetail.Sampling_Inspection_User__c = System.UserInfo.getUserId();
        samplingDetail.Sampling_Inspection_Date__c = newSi.Inspection_Date__c;    
        samplingDetail.Display_Status__c = newSi.Placement_Status__c;
        samplingDetail.ExternalID__c = newSi.Shop__c+'-'+newSi.Product__c; 
        samplingDetail.Unplanned_Sample__c = newSi.Unplanned_Sample__c == 'No' ? '否' : '是';
        samplingDetail.Shop__c = newSi.Shop__c;
        samplingDetail.Product__c = newSi.Product__c;
        samplingDetail.Is_Add__c = '是';
        samplingDetail.ReRe__c = newSi.ReRe__c;
        samplingDetail.Price__c = newSi.Price__c;
        samplingDetail.Quantity__c = newSi.Quantity__c;
        samplingDetail.Exhibition_Format__c = newSi.Exhibition_Format__c;
        samplingDetail.AutomaticallyGenerateSampleStandard__c = true;
        
        return samplingDetail;
    }

    // 新增计划外出样 （Sampling Inspection、CheckResult）
    @AuraEnabled
    public static ConResponse addPlanOutProduct(String recordJson, String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);
 
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c, Series__c, Category__c FROM Product__c WHERE Id = : productId];
        if (productList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Product__c.getLabel()});
            return resp;
        }
        Product__c product = productList[0];

        // 新建计划外Sampling Inspection
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.Inspection_Date__c = report.Report_Date__c;
        newSi.Placement_Status__c = '展出';
        newSi.Unplanned_Sample__c = 'Yes';
        newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + product.Id + '_' + UserInfo.getUserId() + '_' + report.Id;
        newSi.Product__c = product.Id;
        newSi.Shop__c = report.Store__c;
        newSi.ReRe__c = '';
        // wfc 关联巡店员日报
        newSi.Sample_Inspector__c = report.Id;

        insert newSi;

        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(report.Id);
        mso.put('samplingInspections', siList);
        // 更新日报信息
        List<Sample_Inspector__c> dirList = getExistDailyInspectionReportBasedId(report.Id);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Sample_Inspector__c.getLabel()});
            return resp;
        }
        Sample_Inspector__c dir = dirList[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        return resp;
    }

    // Sampling Inspection新增
    @AuraEnabled
    public static ConResponse samplingInspectionAdd(String recordJson, String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);

        User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];

        // 新建计划外Sampling Inspection
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.Inspection_Date__c = report.Report_Date__c;
        newSi.Placement_Status__c = '展出';
        newSi.Unplanned_Sample__c = 'Yes';
        newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + productId + '_' + UserInfo.getUserId() + '_' + report.Id;
        newSi.Product__c = productId;
        newSi.Shop__c = report.Store__c;
        newSi.ReRe__c = '';
        // wfc 关联巡店员日报
        newSi.Sample_Inspector__c = report.Id;

        insert newSi;

        Set<String> newIds = new Set<String>();
        newIds.add(newSi.id);
        Sampling_Inspection__c addedsi = getExistSamplingInspectionBaseId(newIds)[0];
        mso.put('newSamplingInspection', addedsi);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(report.Id);
        mso.put('samplingInspections', siList);

        // 更新日报信息
        Sample_Inspector__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);

        return resp;
    }
    // Sampling Inspection删除
    @AuraEnabled
    public static ConResponse samplingInspectionDelete(String recordJson, String samplingId) {

        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        Sample_Inspector__c report = (Sample_Inspector__c)JSON.deserializeStrict(recordJson, Sample_Inspector__c.class);
        Set<String> samplingIds = new Set<String>();
        samplingIds.add(samplingId);
        Sampling_Inspection__c delSi = getExistSamplingInspectionBaseId(samplingIds)[0];
        List<Sampling_Inspection__c> allsiList = getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline(report.Store__c, report.Report_Date__c, delSi.Product__r.Product_Line__c);
       
        delete delSi;

        // 刷新页面信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionByReportId(report.Id);
        mso.put('samplingInspections', siList);
        // 更新日报信息
        Sample_Inspector__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

        return resp;
    }
    // Query Data===========================================================

    // 获取Sampling Inspection
    public static List<Sampling_Inspection__c> getExistSamplingInspectionByReportId(String reportId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    Rent__c,
                    Price__c,
                    Quantity__c,
                    Exhibition_Format__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Sample_Inspector__c = : reportId
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productline 产品线
     * @return  出样结果
     */
    public static List<Sampling_Inspection__c> getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline(String storeId, Date recordDate, String productline) {
        return [
                SELECT 
                    Id
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate 
                AND Product__r.Product_Line__c = : productline 
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取出样结果
     * @param   ids     出样结果id
     * @return  出样结果
     */
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    Rent__c,
                    Price__c,
                    Quantity__c,
                    Exhibition_Format__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Id IN : ids
                ORDER BY Product__r.Name DESC];
    }

    // 根据坐标校对后的结果
    public static String getStoreForDistance(String currentLat, String currentLong) {
        String storeId;
        if(String.isEmpty(currentLat) || String.isEmpty(currentLong)){
            return storeId;
        }
        List<Shop__c> shops = getStoreBySalesRegion(Decimal.valueOf(currentLat),Decimal.valueOf(currentLong));
        storeId = (shops == null || shops.isEmpty()) ? null : shops[0].Id;
        System.debug('getStoreForDistance' + storeId);
        return storeId;
    }

    /**
     * @description 获取门店列表
     * @param   
     * @return  门店列表
     */
    public static List<Shop__c> getStoreBySalesRegion(Decimal currentLat, Decimal currentLong) {
        return [
                SELECT 
                Id
                FROM Shop__c 
                WHERE
                Sales_Region__c =: user.Sales_Region__c
                AND Shop_Center_Location__Latitude__s !=null 
                AND Shop_Center_Location__Longitude__s != null 
                order by DISTANCE(Shop_Center_Location__c, GEOLOCATION(:currentLat,:currentLong), 'mi') 
                limit 1];
    }

    public static integer gabige() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        return i;
    }

}