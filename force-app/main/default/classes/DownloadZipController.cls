/*
 * @Author: WFC
 * @Date: 2024-09-18 16:04:57
 * @LastEditors: WFC
 * @LastEditTime: 2025-11-05 18:11:06
 * @Description: Zippex只能压缩文件不能压缩图片
 * DownloadZipController.zipData();
 * @FilePath: \testuat\force-app\main\default\classes\DownloadZipController.cls
 */
public without sharing class DownloadZipController{
    private final static String SITE_URL_MID = '/sfc/servlet.shepherd/document/download/';
    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    // public transient Blob fileUploadBody1{ get; set; }
    // public String fileUploadName1{ get; set; }
    // public transient Blob fileUploadBody2{ get; set; }
    // public String fileUploadName2{ get; set; }
    // public transient Blob fileUploadBody3{ get; set; }
    // public String fileUploadName3{ get; set; }
    // public transient Map<String, Blob> fileNameToBody{ get; set; }
    // public PageReference reference{ get; set; }
    // public PageReference downloadZip(){
    //     String zipName = 'testZip.zip';
    //     String prefixFolder = 'folder/';
    //     fileNameToBody = new Map<String, Blob>();
    //     if (fileUploadName1 != null && fileUploadBody1 != null){
    //         fileNameToBody.put(fileUploadName1, fileUploadBody1);
    //     }
    //     if (fileUploadName2 != null && fileUploadBody2 != null){
    //         fileNameToBody.put(fileUploadName2, fileUploadBody2);
    //     }
    //     if (fileUploadName3 != null && fileUploadBody3 != null){
    //         fileNameToBody.put(fileUploadName3, fileUploadBody3);
    //     }
    //     Zippex zip = new Zippex();
    //     for (String fileName : fileNameToBody.keySet()){
    //         zip.addFile(prefixFolder + fileName, fileNameToBody.get(fileName), null);
    //     }
    //     try{
    //         Document doc = new Document();
    //         doc.FolderId = UserInfo.getUserId();
    //         doc.Name = zipName;
    //         doc.Body = zip.getZipArchive();
    //         insert doc;
    //         return new PageReference('/servlet/servlet.FileDownload?file=' + doc.Id);
    //     } catch (Exception ex){
    //         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, '生成zip失败'));
    //     }
    //     return null;
    // }
    // public static void zipData(){
    //     String zipName = 'testZip.zip';
    //     String prefixFolder = 'folder/';
    //     ContentVersion cv = [SELECT Id, VersionData, Title, ContentDocument.FileExtension
    //                          FROM ContentVersion
    //                          WHERE Id = '068Hz0000020JzZIAU'];
    //     String fileName = cv.Title;
    //     String fileType = cv.ContentDocument.FileExtension;
    //     if (fileName.lastIndexOf('.' + fileType) < 0){
    //         fileName = cv.Title + '.' + cv.ContentDocument.FileExtension;
    //     }
    //     String hexStr = EncodingUtil.convertToHex(cv.VersionData);
    //     Integer b = 0;
    //     Integer crc = -1;
    //     Integer size = hexStr.length();
    //     for (Integer i = 0; i < size; i += 2){
    //         b = ((hexStr.charAt(i) & 15) + (hexStr.charAt(i) >>> 6) * 9) * 16 | (hexStr.charAt(i + 1) & 15) + (hexStr.charAt(i + 1) >>> 6) * 9;
    //         crc = (crc >>> 8) ^ HexUtil.table[(crc ^ b) & 255];
    //     }
    //     crc = crc ^ -1;
    //     Zippex zip = new Zippex();
    //     zip.addFile(fileName, cv.VersionData, HexUtil.intToHexLE(crc, 4));
    //     Document doc = new Document();
    //     doc.FolderId = UserInfo.getUserId();
    //     doc.Name = zipName;
    //     doc.Body = zip.getZipArchive();
    //     insert doc;
    // }
    // @AuraEnabled
    // public static Map<String, Object> downloadZip(String shopId, Date dateStart, Date dateEnd){
    //     Map<String, Object> resp = new Map<String, Object>();
    //     // 查询当前用户门店日期下所有日报的检查项
    //     List<CheckResult__c> checkResultList = [SELECT Id, InspectorDailyReport__r.Report_Date__c, CheckItem__r.Description__c, Result__c
    //                                             FROM CheckResult__c
    //                                             WHERE InspectorDailyReport__r.Store__c = :shopId
    //                                             AND InspectorDailyReport__r.Report_Date__c >= :dateStart
    //                                             AND InspectorDailyReport__r.Report_Date__c <= :dateEnd
    //                                             // AND InspectorDailyReport__r.OwnerId = :UserInfo.getUserId()
    //     ];
    //     LisqContainer checkResultListLc = new LisqContainer(checkResultList);
    //     List<String> checkResultIdList = checkResultListLc.ToIds();
    //     // checkResult 日期map集合
    //     Map<Date, List<CheckResult__c>> checkResultMap = new Map<Date, List<CheckResult__c>>();
    //     for (CheckResult__c cr : checkResultList){
    //         if (checkResultMap.containsKey(cr.InspectorDailyReport__r.Report_Date__c)){
    //             List<CheckResult__c> tempList = checkResultMap.get(cr.InspectorDailyReport__r.Report_Date__c);
    //             tempList.add(cr);
    //             checkResultMap.put(cr.InspectorDailyReport__r.Report_Date__c, tempList);
    //         } else{
    //             List<CheckResult__c> tempList = new List<CheckResult__c>();
    //             tempList.add(cr);
    //             checkResultMap.put(cr.InspectorDailyReport__r.Report_Date__c, tempList);
    //         }
    //     }
    //     // 查询相关的文件
    //     List<ContentDocumentLink> documentList = [SELECT Id, ContentDocument.LatestPublishedVersion.VersionData, LinkedEntityId
    //                                               FROM ContentDocumentLink
    //                                               WHERE LinkedEntityId IN:checkResultIdList];
    //     LisqContainer documentListLc = new LisqContainer(documentList);
    //     Map<String, List<ContentDocumentLink>> contentDocumentMap = new Map<String, List<ContentDocumentLink>>();
    //     for (ContentDocumentLink cd : documentList){
    //         if (contentDocumentMap.containsKey(cd.LinkedEntityId)){
    //             List<ContentDocumentLink> tempList = contentDocumentMap.get(cd.LinkedEntityId);
    //             tempList.add(cd);
    //             contentDocumentMap.put(cd.LinkedEntityId, tempList);
    //         } else{
    //             List<ContentDocumentLink> tempList = new List<ContentDocumentLink>();
    //             tempList.add(cd);
    //             contentDocumentMap.put(cd.LinkedEntityId, tempList);
    //         }
    //     }
    //     // 日期map
    //     List<Object> resultList = new List<Object>();
    //     // Map<Date, List<ContentDocumentLink>> resultMap = new Map<Date, List<ContentDocumentLink>>();
    //     for (Date i = dateStart; i <= dateEnd; i = i.addDays(1)){
    //         Map<String, Object> tempMap = new Map<String, Object>();
    //         List<Object> tempList = new List<Object>();
    //         Map<String, Object> tempCheckResultMap = new Map<String, Object>();
    //         // 获取checkResult
    //         List<CheckResult__c> crList = checkResultMap.get(i);
    //         if (crList != null){
    //             for (CheckResult__c cr : crList){
    //                 if(contentDocumentMap.get(cr.Id) != null){
    //                     tempCheckResultMap.put('checkResult', cr);
    //                     tempCheckResultMap.put('checkItem', cr.CheckItem__r.Description__c);
    //                     tempCheckResultMap.put('checkItemResponse', cr.Result__c);
    //                     tempList.add(tempCheckResultMap);
    //                 }
    //             }
    //         }
    //         tempMap.put('dateInfo', i);
    //         tempMap.put('dateDocument', tempList);
    //         resultList.add(tempMap);
    //     }
    //     // 运行batch生成zip
    //     DownloadZipBatchable dz  = new DownloadZipBatchable(checkResultIdList);
    //     String batchId = Database.executeBatch(dz);
    //     resp.put('isSuccess', true);
    //     resp.put('result', resultList);
    //     resp.put('batchId', batchId);
    //     return resp;
    // }


    //新逻辑
    @AuraEnabled
    public static Map<String, Object> searchDownloadPhoto(String shopId, Date dateStart, Date dateEnd, String channel, String walker){
        Map<String, Object> resp = new Map<String, Object>();
        String sr = currentUser.Sales_Region__c;      
        List<Inspection_Photo_Download__c> downloadList = Database.query(String.join(new String[] {
            ' SELECT',
            ' Id,Inspection_Date__c,Item_Type__c,Description__c,DocumentId__c,PhotoId__c,Store__c,Store_Name__c ',
            'FROM Inspection_Photo_Download__c',
            'WHERE ',
            '   SBU__c =: sr',
            '   AND Inspection_Date__c >= :dateStart',
            '   AND Inspection_Date__c <= :dateEnd',
            String.isEmpty(shopId) ? '' : '   AND Store__c = :shopId',
            // channel == null ? '' :'   AND InspectorDailyReport__r.Store__r.Channel_item__c = :channel',
            String.isEmpty(walker) ? '' : '   AND InspectorDailyReport__r.OwnerId =: walker',
            ''
        }, ' '));
        if(downloadList.size() == 0){
            //处理日期集合
            List<Object> resultList = new List<Object>();
            for (Date i = dateStart; i <= dateEnd; i = i.addDays(1)){
                Map<String, Object> tempMap = new Map<String, Object>();
                List<Object> tempList = new List<Object>();
                tempMap.put('dateInfo', i);
                tempMap.put('dateDocument', tempList);
                resultList.add(tempMap);
            }
            resp.put('result', resultList);
            resp.put('urlList',null);
            resp.put('total',0);
            return resp;
        }
        Map<Date, List<Inspection_Photo_Download__c>> photoResultMap = new Map<Date, List<Inspection_Photo_Download__c>>();
        Map<Date, List<String>> documentIdsByDate = new Map<Date, List<String>>();
        System.debug('数据总量' + downloadList.size());
        for (Inspection_Photo_Download__c load : downloadList) {
            if (!documentIdsByDate.containsKey(load.Inspection_Date__c)) {
                documentIdsByDate.put(load.Inspection_Date__c, new List<String>());
            }
            documentIdsByDate.get(load.Inspection_Date__c).add(load.DocumentId__c);
        }

        List<Inspection_Photo_Download__c> UniqueDownloadList = getUniqueARecords(downloadList);
        for (Inspection_Photo_Download__c result : UniqueDownloadList) {
            if (photoResultMap.containsKey(result.Inspection_Date__c)){
                List<Inspection_Photo_Download__c> tempList = photoResultMap.get(result.Inspection_Date__c);
                tempList.add(result);
                photoResultMap.put(result.Inspection_Date__c, tempList);
            } else{
                List<Inspection_Photo_Download__c> tempList = new List<Inspection_Photo_Download__c>();
                tempList.add(result);
                photoResultMap.put(result.Inspection_Date__c, tempList);
            }
        }

        List<Object> resultList = new List<Object>();
        for (Date i = dateStart; i <= dateEnd; i = i.addDays(1)) {
            Map<String, Object> tempMap = new Map<String, Object>();
            Map<String, List<Object>> itemTypeMap = new Map<String, List<Object>>(); // 用于按 Item_Type__c 分组
        
            // 获取checkResult
            List<Inspection_Photo_Download__c> crList = photoResultMap.containsKey(i) ? photoResultMap.get(i) : new List<Inspection_Photo_Download__c>();
            if (crList != null) {
                for (Inspection_Photo_Download__c cr : crList) {
                    if (cr.PhotoId__c != null) {
                        Map<String, Object> tempCheckResultMap = new Map<String, Object>();
                        tempCheckResultMap.put('checkResult', cr);
                        tempCheckResultMap.put('checkItemType', cr.Item_Type__c);
                        tempCheckResultMap.put('checkItem', cr.Description__c);
                        tempCheckResultMap.put('checkItemResponse', '');
                    
                        // 根据 Item_Type__c 分组
                        String itemType = cr.Item_Type__c;
                        if (!itemTypeMap.containsKey(itemType)) {
                            itemTypeMap.put(itemType, new List<Object>());
                        }
                        itemTypeMap.get(itemType).add(tempCheckResultMap);
                    }
                }
                
            }
            tempMap.put('dateInfo', i);
            tempMap.put('dateDocument', itemTypeMap); // 存储按 Item_Type__c 分组后的数据
            resultList.add(tempMap);
        }
        resp.put('isSuccess', true);
        resp.put('result', resultList);
        resp.put('urlList',concatenateStringsInBatches(documentIdsByDate));
        resp.put('total', downloadList.size());
        return resp;
    }

    //去重
    @AuraEnabled
    public static List<Inspection_Photo_Download__c> getUniqueARecords(List<Inspection_Photo_Download__c> resultList) {
        // 使用 Map 去重
        Map<String, Inspection_Photo_Download__c> uniqueAMap = new Map<String, Inspection_Photo_Download__c>();
        for (Inspection_Photo_Download__c result : resultList) {
            // 使用 PhotoId 作为键，确保每个 PhotoId 只出现一次
            uniqueAMap.put(result.PhotoId__c, result);
        }

        // 将 Map 的值转换为 List
        List<Inspection_Photo_Download__c> uniqueAList = new List<Inspection_Photo_Download__c>(uniqueAMap.values());

        return uniqueAList;
    }

    //用于整合
    @AuraEnabled
    public static Map<String, Object> searchSample(String shopId, Date dateStart, Date dateEnd, String channel, String walker){
        Map<String, Object> resp = new Map<String, Object>();
        Map<Date, List<CheckResult__c>> checkResultMap = new Map<Date, List<CheckResult__c>>();
        Map<String, LisqContainer> contentDocumentMap = new Map<String, LisqContainer>();
        Map<Date, List<String>> contentDocumentIdsByDate = new Map<Date, List<String>>();
        LisqContainer contentDocumentListLc;
        Map<String, Object> sampleSP = sampleResult(shopId,  dateStart,  dateEnd,  channel,  walker); 
        Map<Date, List<Sampling_Inspection__c>> sampleDateMap = (Map<Date, List<Sampling_Inspection__c>>)sampleSP.get('sample');
        Map<Date, List<String>> sampleDocumentIdsByDate = (Map<Date, List<String>>)sampleSP.get('samplePhoto');
        Map<String, LisqContainer> sampleDocumentIds = (Map<String, LisqContainer>)sampleSP.get('sampleDocumentIds');
        System.debug('sampleSP!' + sampleDateMap);
        System.debug('sampleSP!!' + sampleDocumentIdsByDate);
        System.debug('sampleSP!!!' + sampleDocumentIds);
        String sr = currentUser.Sales_Region__c;      
        List<CheckResult__c> checkList = 
        Database.query(String.join(new String[] {
            'SELECT',
            '   Id ',
            'FROM CheckResult__c',
            'WHERE ',
            '   InspectorDailyReport__r.Sales_Region__c =: sr',
            '   AND InspectorDailyReport__r.Report_Date__c >= :dateStart',
            '   AND InspectorDailyReport__r.Report_Date__c <= :dateEnd',
            shopId == null ? '' : '   AND InspectorDailyReport__r.Store__c = :shopId',
            '   AND InspectorDailyReport__r.Status__c = \'' + 'Submitted' +'\'',
            channel == null ? '' :'   AND InspectorDailyReport__r.Store__r.Channel_item__c = :channel',
            walker == null ? '' : '   AND InspectorDailyReport__r.OwnerId =: walker',
            ''
        }, ' '));
        Set<Id> idList = new Set<Id>();
        for (CheckResult__c result : checkList) {
            idList.add(result.Id);
        }
        if(idList.size() == 0 && sampleSP.isEmpty()){
            //处理日期集合
            List<Object> resultList = new List<Object>();
            for (Date i = dateStart; i <= dateEnd; i = i.addDays(1)){
                Map<String, Object> tempMap = new Map<String, Object>();
                List<Object> tempList = new List<Object>();
                tempMap.put('dateInfo', i);
                tempMap.put('dateDocument', tempList);
                resultList.add(tempMap);
            }
            resp.put('result', resultList);
            resp.put('urlList',null);
            return resp;
        }
        // List<Id>)
        // 查询所有的ContentDocumentLink
        if(idList.size() > 0) {
            List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId,ContentDocumentId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.PathOnClient
                                                             FROM ContentDocumentLink
                                                             WHERE LinkedEntityId in :idList];
            contentDocumentListLc = new LisqContainer(contentDocumentList);
            
            // Map集合 CheckResult__c Id
            contentDocumentMap = contentDocumentListLc.GroupByS('LinkedEntityId');
            // 查询所有的CheckResult__c
            List<CheckResult__c> checkResultList = [SELECT Id, InspectorDailyReport__r.Report_Date__c, CheckItem__r.Description__c,CheckItem__r.Item_Type__c, Response__c,Result__c
                                                    FROM CheckResult__c
                                                    WHERE Id IN:contentDocumentMap.keySet()];
            contentDocumentIdsByDate = groupContentDocumentIdsByDate(checkResultList, contentDocumentList);
            LisqContainer checkResultListLc = new LisqContainer(checkResultList);
            List<String> checkResultIdList = checkResultListLc.ToIds();
            // 处理数据
            Map<String, List<CheckResult__c>> itemTypeResultMap = new Map<String, List<CheckResult__c>>();
            
            for (CheckResult__c cr : checkResultList){
                if (checkResultMap.containsKey(cr.InspectorDailyReport__r.Report_Date__c)){
                    List<CheckResult__c> tempList = checkResultMap.get(cr.InspectorDailyReport__r.Report_Date__c);
                    tempList.add(cr);
                    checkResultMap.put(cr.InspectorDailyReport__r.Report_Date__c, tempList);
                } else{
                    List<CheckResult__c> tempList = new List<CheckResult__c>();
                    tempList.add(cr);
                    checkResultMap.put(cr.InspectorDailyReport__r.Report_Date__c, tempList);
                }
            }
        }
        
        List<Object> resultList = new List<Object>();
        for (Date i = dateStart; i <= dateEnd; i = i.addDays(1)) {
            Map<String, Object> tempMap = new Map<String, Object>();
            Map<String, List<Object>> itemTypeMap = new Map<String, List<Object>>(); // 用于按 Item_Type__c 分组
        
            // 获取checkResult
            List<CheckResult__c> crList = checkResultMap.containsKey(i) ? checkResultMap.get(i) : new List<CheckResult__c>();
            if (crList != null) {
                for (CheckResult__c cr : crList) {
                    if (contentDocumentMap.get(cr.Id) != null) {
                        Map<String, Object> tempCheckResultMap = new Map<String, Object>();
                        tempCheckResultMap.put('checkResult', cr);
                        tempCheckResultMap.put('checkItemType', cr.CheckItem__r.Item_Type__c);
                        tempCheckResultMap.put('checkItem', cr.CheckItem__r.Description__c);
                        String str = String.isEmpty(cr.Response__c) ? cr.Result__c : cr.Response__c;
                        tempCheckResultMap.put('checkItemResponse', str);
                    
                        // 根据 Item_Type__c 分组
                        String itemType = cr.CheckItem__r.Item_Type__c;
                        if (!itemTypeMap.containsKey(itemType)) {
                            itemTypeMap.put(itemType, new List<Object>());
                        }
                        itemTypeMap.get(itemType).add(tempCheckResultMap);
                    }
                }
                
            }
            List<Sampling_Inspection__c> sampleList = sampleDateMap.get(i);
            if (sampleList != null) {
                for (Sampling_Inspection__c cr : sampleList) {
                    if (sampleDocumentIds.get(cr.Id) != null) {
                        Map<String, Object> tempCheckResultMap = new Map<String, Object>();
                        tempCheckResultMap.put('checkResult', cr);
                        tempCheckResultMap.put('checkItemType', System.Label.Sample_Display);
                        tempCheckResultMap.put('checkItem', cr.Product__r.Name);
                        String str = String.isNotEmpty(cr.Placement_Status__c) && '展出'.equals(cr.Placement_Status__c) ? 'Yes' : 'No';
                        tempCheckResultMap.put('checkItemResponse', str);
                    
                        // 根据 Item_Type__c 分组
                        String itemType = System.Label.Sample_Display;
                        if (!itemTypeMap.containsKey(itemType)) {
                            itemTypeMap.put(itemType, new List<Object>());
                        }
                        itemTypeMap.get(itemType).add(tempCheckResultMap);
                    }
                }
            }
            tempMap.put('dateInfo', i);
            tempMap.put('dateDocument', itemTypeMap); // 存储按 Item_Type__c 分组后的数据
            resultList.add(tempMap);
        }
        for (Date key : sampleDocumentIdsByDate.keySet()) {
            if (contentDocumentIdsByDate.containsKey(key)) {
                contentDocumentIdsByDate.get(key).addAll(sampleDocumentIdsByDate.get(key));
            } else {
                contentDocumentIdsByDate.put(key, sampleDocumentIdsByDate.get(key));
            }
        }
        if (contentDocumentListLc != null && contentDocumentListLc.Size() > 0){
            // 运行batch生成zip
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            // DownloadZipBatchable dz = new DownloadZipBatchable(checkResultIdList, h);
            // String batchId = Database.executeBatch(dz, 1);

            resp.put('isSuccess', true);
            // resp.put('batchId', batchId);
            resp.put('key', h);
        }else {
            resp.put('isSuccess', false);
        }
        resp.put('result', resultList);
        resp.put('urlList',concatenateStringsInBatches(contentDocumentIdsByDate));
        return resp;
    }

    @AuraEnabled
    public static Map<String, Object> sampleResult(String shopId, Date dateStart, Date dateEnd, String channel, String walker){
        Map<String, Object> resp = new Map<String, Object>();
        Map<Date, List<String>> contentDocumentIdsByDate = new Map<Date, List<String>>(); 
        Map<String, LisqContainer> contentDocumentMap = new Map<String, LisqContainer> ();
        Map<Date, List<Sampling_Inspection__c>> checkResultMap = new Map<Date, List<Sampling_Inspection__c>>();
        String sr = currentUser.Sales_Region__c;   
        List<Sampling_Inspection__c> checkList = 
        Database.query(String.join(new String[] {
            'SELECT',
            '   Id ',
            'FROM Sampling_Inspection__c ',
            'WHERE ',
            '   Inspection_Report__r.Sales_Region__c =: sr',
            '   AND Inspection_Report__r.Report_Date__c >= :dateStart',
            '   AND Inspection_Report__r.Report_Date__c <= :dateEnd',
            shopId == null ? '' : '   AND Shop__c = :shopId',
            '   AND Inspection_Report__r.Status__c = \'' + 'Submitted' +'\'',
            channel == null ? '' :'   AND Shop__r.Channel_item__c = :channel',
            walker == null ? '' : '   AND OwnerId =: walker',
            ''
        }, ' '));
        Set<Id> idList = new Set<Id>();
        for (Sampling_Inspection__c result : checkList) {
            idList.add(result.Id);
        }
        if(idList.size() == 0 ){
            if(idList.size() == 0 ){
            resp.put('sample', checkResultMap);
            resp.put('samplePhoto', contentDocumentIdsByDate);
            resp.put('sampleDocumentIds', contentDocumentMap);
            return resp;
        }
        }
        // List<Id>)
        // 查询所有的ContentDocumentLink
        List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId,ContentDocumentId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.PathOnClient
                                                         FROM ContentDocumentLink
                                                         WHERE LinkedEntityId in :idList];
        LisqContainer contentDocumentListLc = new LisqContainer(contentDocumentList);
        //仅获取 对应图片Id
        // List<String> contentDocumentIds= new List<String>();
        // for (ContentDocumentLink cdl : contentDocumentList){
        //     contentDocumentIds.add(cdl.ContentDocumentId);
        // }
        
        // Map集合 CheckResult__c Id
        contentDocumentMap = contentDocumentListLc.GroupByS('LinkedEntityId');
        // 查询所有的CheckResult__c
        List<Sampling_Inspection__c> checkResultList = [SELECT Id, Inspection_Report__r.Report_Date__c, Placement_Status__c, Product__r.Name
                                                FROM Sampling_Inspection__c
                                                WHERE Id IN:contentDocumentMap.keySet()];
        contentDocumentIdsByDate = sampleContentDocumentIdsByDate(checkResultList, contentDocumentList);
        LisqContainer checkResultListLc = new LisqContainer(checkResultList);
        List<String> checkResultIdList = checkResultListLc.ToIds();
        // 处理数据
        Map<String, List<Sampling_Inspection__c>> itemTypeResultMap = new Map<String, List<Sampling_Inspection__c>>();
        for (Sampling_Inspection__c cr : checkResultList){
            if (checkResultMap.containsKey(cr.Inspection_Report__r.Report_Date__c)){
                List<Sampling_Inspection__c> tempList = checkResultMap.get(cr.Inspection_Report__r.Report_Date__c);
                tempList.add(cr);
                checkResultMap.put(cr.Inspection_Report__r.Report_Date__c, tempList);
            } else{
                List<Sampling_Inspection__c> tempList = new List<Sampling_Inspection__c>();
                tempList.add(cr);
                checkResultMap.put(cr.Inspection_Report__r.Report_Date__c, tempList);
            }
        }
        resp.put('sample', checkResultMap);
        resp.put('samplePhoto', contentDocumentIdsByDate);
        resp.put('sampleDocumentIds', contentDocumentMap);
        return resp;
    }

    @AuraEnabled
    public static Map<Date, List<String>> groupContentDocumentIdsByDate(List<CheckResult__c> checkList, List<ContentDocumentLink> contentDocumentList) {
        Map<Date, List<String>> contentDocumentIdsByDate = new Map<Date, List<String>>();
        Map<Id, List<String>> contentDocumentIdsByLinkedEntityId = new Map<Id, List<String>>();

        // 首先，将所有 ContentDocumentLink 按 LinkedEntityId 分组
        for (ContentDocumentLink cdl : contentDocumentList) {
            if (!contentDocumentIdsByLinkedEntityId.containsKey(cdl.LinkedEntityId)) {
                contentDocumentIdsByLinkedEntityId.put(cdl.LinkedEntityId, new List<String>());
            }
            contentDocumentIdsByLinkedEntityId.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
        }

        // 然后，根据 CheckResult__c 的日期分组
        for (CheckResult__c checkResult : checkList) {
            Date reportDate = checkResult.InspectorDailyReport__r.Report_Date__c;
            Id linkedEntityId = checkResult.Id;

            // 如果当前日期已经存在于 Map 中，则直接获取对应的列表
            if (!contentDocumentIdsByDate.containsKey(reportDate)) {
                contentDocumentIdsByDate.put(reportDate, new List<String>());
            }

            // 将当前 CheckResult__c 对应的 ContentDocumentId 添加到日期分组中
            if (contentDocumentIdsByLinkedEntityId.containsKey(linkedEntityId)) {
                contentDocumentIdsByDate.get(reportDate).addAll(contentDocumentIdsByLinkedEntityId.get(linkedEntityId));
            }
        }

        return contentDocumentIdsByDate;
    }

    @AuraEnabled
    public static Map<Date, List<String>> sampleContentDocumentIdsByDate(List<Sampling_Inspection__c> checkList, List<ContentDocumentLink> contentDocumentList) {
        Map<Date, List<String>> contentDocumentIdsByDate = new Map<Date, List<String>>();
        Map<Id, List<String>> contentDocumentIdsByLinkedEntityId = new Map<Id, List<String>>();

        // 首先，将所有 ContentDocumentLink 按 LinkedEntityId 分组
        for (ContentDocumentLink cdl : contentDocumentList) {
            if (!contentDocumentIdsByLinkedEntityId.containsKey(cdl.LinkedEntityId)) {
                contentDocumentIdsByLinkedEntityId.put(cdl.LinkedEntityId, new List<String>());
            }
            contentDocumentIdsByLinkedEntityId.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
        }

        // 然后，根据 CheckResult__c 的日期分组
        for (Sampling_Inspection__c checkResult : checkList) {
            Date reportDate = checkResult.Inspection_Report__r.Report_Date__c;
            Id linkedEntityId = checkResult.Id;

            // 如果当前日期已经存在于 Map 中，则直接获取对应的列表
            if (!contentDocumentIdsByDate.containsKey(reportDate)) {
                contentDocumentIdsByDate.put(reportDate, new List<String>());
            }

            // 将当前 CheckResult__c 对应的 ContentDocumentId 添加到日期分组中
            if (contentDocumentIdsByLinkedEntityId.containsKey(linkedEntityId)) {
                contentDocumentIdsByDate.get(reportDate).addAll(contentDocumentIdsByLinkedEntityId.get(linkedEntityId));
            }
        }

        return contentDocumentIdsByDate;
    }

    

    //增加一个数据拼接处理的方法
    @AuraEnabled
    public static List<String> concatenateStringsInBatches(Map<Date, List<String>> contentDocumentIdsByDate) {
        String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm();
        List<String> resultStrings = new List<String>();
        
        // 检查输入列表是否为空
        if (contentDocumentIdsByDate == null || contentDocumentIdsByDate.isEmpty()) {
            return resultStrings;
        }
        
        // 每50个元素一组进行拼接
        Integer batchSize = 50;
        for (Date analysis : contentDocumentIdsByDate.keySet()) {
            List<String> inputList = contentDocumentIdsByDate.get(analysis);
            System.debug('打印数据集' + analysis + ':' + inputList.size());
            for (Integer i = 0; i < inputList.size(); i += batchSize) {
                String batchString = concatenateBatch(inputList, i, batchSize);
                // 将拼接后的字符串添加到结果列表
                resultStrings.add(SITE_URL_FRO + SITE_URL_MID + batchString);
            }
        }
        System.debug('URL个数' + resultStrings.size());
        return resultStrings;
    }

    @AuraEnabled
    public static String concatenateBatch(List<String> inputList, Integer startIndex, Integer batchSize) {
        Integer endIndex = Math.min(startIndex + batchSize, inputList.size());
        String batchString = inputList[startIndex];
        for (Integer i = startIndex + 1; i < endIndex; i++) {
            batchString += '/' + inputList[i];
        }
        return batchString;
    }


    // @AuraEnabled(cacheable = true)
    // public static Map<String, Object> checkBatchProgress(String batchId){
    //     Map<String, Object> resp = new Map<String, Object>();
    //     AsyncApexJob aaj = [SELECT Id, JobItemsProcessed, TotalJobItems, Status
    //                         FROM AsyncApexJob
    //                         WHERE Id = :batchId
    //                         LIMIT 1];
    //     Decimal totalNum = Decimal.valueOf(aaj.TotalJobItems);
    //     Decimal processNum = Decimal.valueOf(aaj.JobItemsProcessed);
    //     resp.put('isLoadingProgess', totalNum > 0 ? Math.Round(processNum * 100 / totalNum).toString() : '0');
    //     resp.put('Status', aaj.Status);
    //     return resp;
    // }

    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getDataResult(){
        List<Map<String, String>> channelResult = new List<Map<String, String>>();
        List<Map<String, String>> ownerResult = new List<Map<String, String>>();
        Set<String> processedNames = new Set<String>();
        Set<String> ownerNames = new Set<String>();
        Map<String, String> channelMap = new Map<String, String>();        
        channelMap.put('label', '--None--');
        channelMap.put('value', null); 
        channelResult.add(channelMap);
        Map<String, String> ownerMap = new Map<String, String>();           
        ownerMap.put('label', '--None--');
        ownerMap.put('value', null); 
        ownerResult.add(ownerMap);
        Date currentDate = Date.today();
        Date previousDate = currentDate.addDays(-1);
        Date firstDayOfMonth = Date.newInstance(currentDate.year(), currentDate.month(), 1); 
        Map<String, Object> resp = new Map<String, Object>();
        List<Id> idList = new List<Id>();
        List<Id> sampleIdList = new List<Id>();
        List<CheckResult__c> checkList = [SELECT Id, InspectorDailyReport__r.Store__r.Channel_item__c, InspectorDailyReport__r.Store__r.Channel_Name__c,
        InspectorDailyReport__r.OwnerId,InspectorDailyReport__r.Owner_text__c 
        FROM CheckResult__c 
        WHERE InspectorDailyReport__r.Report_Date__c >= :firstDayOfMonth AND InspectorDailyReport__r.Report_Date__c <= :previousDate And InspectorDailyReport__r.Sales_Region__c =: currentUser.Sales_Region__c AND InspectorDailyReport__r.Status__c =: 'Submitted'];
        
        List<Sampling_Inspection__c> sampleList = [SELECT Id, Shop__r.Channel_item__c, Shop__r.Channel_Name__c,
        Inspection_Report__r.OwnerId,Inspection_Report__r.Owner_text__c 
        FROM Sampling_Inspection__c  
        WHERE Inspection_Report__r.Report_Date__c >= :firstDayOfMonth AND Inspection_Report__r.Report_Date__c <= :previousDate And Inspection_Report__r.Sales_Region__c =: currentUser.Sales_Region__c AND Inspection_Report__r.Status__c =: 'Submitted'];
        
        // Inspection_Report__r <==> Sampling_Inspection__c 
        
        for (CheckResult__c result : checkList) {
            idList.add(result.Id);
        }
        for (Sampling_Inspection__c result : sampleList) {
            sampleIdList.add(result.Id);
        }
        if (idList.size() == 0 && sampleIdList.size() == 0) {
            resp.put('channel', channelResult);
            resp.put('owner', ownerResult);
            return resp;
        }

        
        if(idList.size() > 0) {
            List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                                                         FROM ContentDocumentLink
                                                         WHERE LinkedEntityId IN :idList];
            LisqContainer contentDocumentListLc = new LisqContainer(contentDocumentList);
            Map<String, LisqContainer> contentDocumentMap = contentDocumentListLc.GroupByS('LinkedEntityId');
            
            
            Map<Id, CheckResult__c> checkResultStoreNameMap = new Map<Id, CheckResult__c>();
            for (CheckResult__c cr : checkList) {
                checkResultStoreNameMap.put(cr.Id, cr);
            }
            for (String linkedEntityId : contentDocumentMap.keySet()) {
                LisqContainer container = contentDocumentMap.get(linkedEntityId);
                CheckResult__c rp = checkResultStoreNameMap.get(linkedEntityId);
                String channelId = rp.InspectorDailyReport__r.Store__r.Channel_item__c;
                if (String.isNotBlank(channelId) &&!processedNames.contains(channelId)) {
                    Map<String, String> channelMapOne = new Map<String, String>();        
                    channelMapOne.put('label', rp.InspectorDailyReport__r.Store__r.Channel_Name__c);
                    channelMapOne.put('value', rp.InspectorDailyReport__r.Store__r.Channel_item__c);
                    channelResult.add(channelMapOne);
                    processedNames.add(channelId);
                }
                String ownerId = rp.InspectorDailyReport__r.OwnerId;
                if (String.isNotBlank(ownerId) &&!ownerNames.contains(ownerId)) {
                    Map<String, String> ownerMapOne = new Map<String, String>();        
                    ownerMapOne.put('label', rp.InspectorDailyReport__r.Owner_text__c);
                    ownerMapOne.put('value', rp.InspectorDailyReport__r.OwnerId);
                    ownerResult.add(ownerMapOne);
                    ownerNames.add(ownerId);
                }

            }
            
        }
        if(sampleIdList.size() > 0) {
            List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                                                         FROM ContentDocumentLink
                                                         WHERE LinkedEntityId IN :sampleIdList];
            LisqContainer contentDocumentListLc = new LisqContainer(contentDocumentList);
            Map<String, LisqContainer> contentDocumentMap = contentDocumentListLc.GroupByS('LinkedEntityId');
            
            
            Map<Id, Sampling_Inspection__c> checkResultStoreNameMap = new Map<Id, Sampling_Inspection__c>();
            for (Sampling_Inspection__c cr : sampleList) {
                checkResultStoreNameMap.put(cr.Id, cr);
            }
            for (String linkedEntityId : contentDocumentMap.keySet()) {
                LisqContainer container = contentDocumentMap.get(linkedEntityId);
                Sampling_Inspection__c rp = checkResultStoreNameMap.get(linkedEntityId);
                String channelId = rp.Shop__r.Channel_item__c;
                if (String.isNotBlank(channelId) &&!processedNames.contains(channelId)) {
                    Map<String, String> channelMapOne = new Map<String, String>();        
                    channelMapOne.put('label', rp.Shop__r.Channel_Name__c);
                    channelMapOne.put('value', rp.Shop__r.Channel_item__c);
                    channelResult.add(channelMapOne);
                    processedNames.add(channelId);
                }
                String ownerId = rp.Inspection_Report__r.OwnerId;
                if (String.isNotBlank(ownerId) &&!ownerNames.contains(ownerId)) {
                    Map<String, String> ownerMapOne = new Map<String, String>();        
                    ownerMapOne.put('label', rp.Inspection_Report__r.Owner_text__c);
                    ownerMapOne.put('value', rp.Inspection_Report__r.OwnerId);
                    ownerResult.add(ownerMapOne);
                    ownerNames.add(ownerId);
                }

            }
            
        }
        System.debug('channelList' + channelResult);
        System.debug('owner' + ownerResult);
        // resp.put('initShop', initShop);
        // resp.put('initChannel', initChannel);
        resp.put('channel', channelResult);
        resp.put('owner', ownerResult);
        return resp;
    }

    @AuraEnabled
    public static Map<String, Object> getParamResult(Date dateStart, Date dateEnd){
        Set<String> processedNames = new Set<String>();
        Set<String> ownerNames = new Set<String>();
        List<Map<String, String>> channelResult = new List<Map<String, String>>();
        List<Map<String, String>> ownerResult = new List<Map<String, String>>();
        Map<String, String> channelMap = new Map<String, String>();        
        channelMap.put('label', '--None--');
        channelMap.put('value', null); 
        channelResult.add(channelMap);
        Map<String, String> ownerMap = new Map<String, String>();           
        ownerMap.put('label', '--None--');
        ownerMap.put('value', null); 
        ownerResult.add(ownerMap);
        Map<String, Object> resp = new Map<String, Object>();
        List<Id> idList = new List<Id>();
        List<Inspection_Photo_Download__c> photoList = [SELECT Id, Store__r.Channel_item__c, Store__r.Channel_Name__c,
        InspectorDailyReport__r.OwnerId,InspectorDailyReport__r.Owner_text__c 
        FROM Inspection_Photo_Download__c 
        WHERE Inspection_Date__c >= :dateStart AND Inspection_Date__c <= :dateEnd And SBU__c =: currentUser.Sales_Region__c ];
       
        if (photoList.size() == 0) {
            resp.put('channel', channelResult);
            resp.put('owner', ownerResult);
            return resp;
        }
        
        for (Inspection_Photo_Download__c photo : photoList) {
            String channelId = photo.Store__r.Channel_item__c;
            if (String.isNotBlank(channelId) &&!processedNames.contains(channelId)) {
                Map<String, String> channelMapOne = new Map<String, String>();        
                channelMapOne.put('label', photo.Store__r.Channel_Name__c);
                channelMapOne.put('value', photo.Store__r.Channel_item__c);
                channelResult.add(channelMapOne);
                processedNames.add(channelId);
            }
            String ownerId = photo.InspectorDailyReport__r.OwnerId;
            if (String.isNotBlank(ownerId) &&!ownerNames.contains(ownerId)) {
                Map<String, String> ownerMapOne = new Map<String, String>();        
                ownerMapOne.put('label', photo.InspectorDailyReport__r.Owner_text__c);
                ownerMapOne.put('value', photo.InspectorDailyReport__r.OwnerId);
                ownerResult.add(ownerMapOne);
                ownerNames.add(ownerId);
            }
        }
        System.debug('channelList' + channelResult);
        System.debug('owner' + ownerResult);
        resp.put('channel', channelResult);
        resp.put('owner', ownerResult);
        return resp;
    }

    // @AuraEnabled
    // public static List<ContentVersion> getDownloadFileList(String key){
    //     List<ContentVersion> cvList = [SELECT Id, VersionDataUrl, PathOnClient
    //                                    FROM ContentVersion
    //                                    WHERE Download_Key__c = :key
    //                                    ORDER BY PathOnClient];
    //     return cvList;
    // }

    @AuraEnabled
    public static Map<String, Object> getResultByStore(String id, Date dateStart, Date dateEnd){
        System.debug('SHOPID' + id);
        Set<String> processedNames = new Set<String>();
        List<Map<String, String>> walkerResult = new List<Map<String, String>>();
        Map<String, String> walkerMap = new Map<String, String>();        
        walkerMap.put('label', '--None--');
        walkerMap.put('value', null);
        walkerResult.add(walkerMap);
        List<Map<String, String>> channelResult = new List<Map<String, String>>();
        Map<String, Object> resp = new Map<String, Object>();
        List<Id> idList = new List<Id>();
        List<Id> sampleIdList = new List<Id>();
        List<Shop__c> stores = [SELECT Id, Channel_item__c, Channel_Name__c FROM Shop__c WHERE Id = :id LIMIT 1];
        String channelId = stores.isEmpty() ? '' : stores[0].Channel_item__c;
        List<Inspection_Photo_Download__c> photoList = [SELECT Id,InspectorDailyReport__r.OwnerId,InspectorDailyReport__r.Owner_text__c
                                        FROM Inspection_Photo_Download__c 
                                        WHERE  Store__c = :id And Inspection_Date__c >= :dateStart AND Inspection_Date__c <= :dateEnd];

        if (photoList.size() == 0) {
            resp.put('channel', channelResult);
            return resp;
        }
        
        for (Inspection_Photo_Download__c rp : photoList) {
            String ownerId = rp.InspectorDailyReport__r.OwnerId;
            if (String.isNotBlank(ownerId) &&!processedNames.contains(ownerId)) {
                Map<String, String> walkerMapOne = new Map<String, String>(); // 创建一个新的Map          
                walkerMapOne.put('label', rp.InspectorDailyReport__r.Owner_text__c); // 添加label
                walkerMapOne.put('value', rp.InspectorDailyReport__r.OwnerId); // 添加value
                walkerResult.add(walkerMapOne);
                processedNames.add(ownerId);
            }
        }
        System.debug('owner' + walkerResult);
        resp.put('channelId', channelId);
        resp.put('channel', channelResult);
        resp.put('owner', walkerResult);
        return resp;
    }

    //此方法用于重命名图片
    @AuraEnabled
    public static void changeCheckResultPhotoName(Date startDate, Date endDate, String salesRegion){
        // Date resultDate = Date.today(); // 获取当前日期
        // String formattedDate = String.valueOf(param);
        // Date yesterday = param.addDays(-1);

        Map<String, Object> resp = new Map<String, Object>(); 
        List<Id> idList = new List<Id>();

        List<ContentVersion> entitiesToUpdate = new List<ContentVersion>();
        //List<Id> titleId = new List<Id>();
        String regionSql = '';
        if(String.isNotEmpty(salesRegion)) {
            regionSql = ' AND InspectorDailyReport__r.Sales_Region__c = \''+ salesRegion +'\' ';
        }
         String rpSoql = 'SELECT Id, InspectorDailyReport__r.Report_Date__c,InspectorDailyReport__r.Store__r.Channel_Name__c,InspectorDailyReport__r.Sales_Region__c,CheckItem__r.Item_Type__c,InspectorDailyReport__r.Store__c,InspectorDailyReport__r.Store__r.Name FROM CheckResult__c WHERE ';
            rpSoql += ' InspectorDailyReport__r.Report_Date__c >= ' + String.valueOf(startDate);
            rpSoql += ' AND InspectorDailyReport__r.Report_Date__c <= ' + String.valueOf(endDate) ;
            rpSoql += regionSql;
        System.debug('soql=' + rpSoql);
        List<CheckResult__c> checkList = Database.query(rpSoql);
        for (CheckResult__c result : checkList) {
            idList.add(result.Id);
        }
        if (idList.size() == 0) {
            System.debug('没有数据');
            return;
        }

        List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                                                         FROM ContentDocumentLink
                                                         WHERE LinkedEntityId IN :idList];
        Map<String, List<ContentDocumentLink>> entityMap = new Map<String, List<ContentDocumentLink>>();
        if (contentDocumentList.size() > 0) {
            System.debug('图片ID Size=' + contentDocumentList.size());
            for (ContentDocumentLink entity : contentDocumentList) {
                String key = String.valueOf(entity.LinkedEntityId)+ String.valueOf(entity.Id);
                if (!entityMap.containsKey(key)) {
                    entityMap.put(key, new List<ContentDocumentLink>());
                }
                entityMap.get(key).add(entity);
            }
            Map<Id, CheckResult__c> checkResultMap = new Map<Id, CheckResult__c>();
            for (CheckResult__c checkResult : checkList) {
                checkResultMap.put(checkResult.Id, checkResult);
            }
            Map<String, Integer> itemTypeCountMap = new Map<String, Integer>();
            for (String linkedEntityId : entityMap.keySet()) {
                List<ContentDocumentLink> DocumentEntity =  entityMap.get(linkedEntityId);
                String documentId = DocumentEntity[0].LinkedEntityId;
                CheckResult__c checkResult = checkResultMap.get(documentId);
                if (checkResult == null) {
                    System.debug('No CheckResult__c found for LinkedEntityId: ' + documentId);
                    continue;
                }
                // 按 Item_Type__c 分组
                for (ContentDocumentLink entity : entityMap.get(linkedEntityId)) {
                    String itemType = checkResult.CheckItem__r.Item_Type__c;
                    String storeName = checkResult.InspectorDailyReport__r.Store__r.Name;
                    String region = checkResult.InspectorDailyReport__r.Sales_Region__c;
                    String formattedDate = String.valueOf(checkResult.InspectorDailyReport__r.Report_Date__c);
                    String key = region +'_'+ storeName+'_'+ itemType +'_'+ formattedDate;                
                    Integer count = itemTypeCountMap.get(key) == null ? 1 : itemTypeCountMap.get(key) + 1;
                    itemTypeCountMap.put(key, count);
                    String newName = checkResult.InspectorDailyReport__r.Store__r.Channel_Name__c + '_'
                                     + checkResult.InspectorDailyReport__r.Store__r.Name + '_'
                                     + itemType + '_'
                                     + formattedDate + '_'
                                     + count;
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = newName;
                    System.debug('_' + region +'_'+newName);
                    contentVersion.Id = entity.ContentDocument.LatestPublishedVersionId;
                    entitiesToUpdate.add(contentVersion);
                }
            }
        }            
    
        // 更新 ContentVersion 记录
        if (!entitiesToUpdate.isEmpty()) {
            update entitiesToUpdate;
        }
    }

    @AuraEnabled
    public static void changeSamplePhotoName(Date startDate, Date endDate, String salesRegion){
        // Date resultDate = Date.today(); // 获取当前日期
        // String formattedDate = String.valueOf(param);
        // Date yesterday = param.addDays(-1);

        Map<String, Object> resp = new Map<String, Object>(); 
        List<Id> sampleIdList = new List<Id>();
        List<ContentVersion> entitiesToUpdate = new List<ContentVersion>();
        //List<Id> titleId = new List<Id>();
        String sampleRegionSql = '';
        if(String.isNotEmpty(salesRegion)) {
            sampleRegionSql = ' AND Inspection_Report__r.Sales_Region__c = \''+ salesRegion +'\' ';
        }
        String sampleSoql = '';
            sampleSoql += 'SELECT ';
            sampleSoql += 'Id, ';
            sampleSoql += 'Inspection_Report__r.Report_Date__c, ';
            sampleSoql += 'Shop__r.Channel_Name__c, ';
            sampleSoql += 'Inspection_Report__r.Sales_Region__c, ';
            sampleSoql += 'Placement_Status__c, ';
            sampleSoql += 'Product__r.Name, ';
            sampleSoql += 'Shop__c, ';
            sampleSoql += 'Shop__r.Name ';
            sampleSoql += 'FROM Sampling_Inspection__c ';
            sampleSoql += 'WHERE ';
            sampleSoql += ' Inspection_Report__r.Report_Date__c >= ' + String.valueOf(startDate);
            sampleSoql += ' AND Inspection_Report__r.Report_Date__c <= ' + String.valueOf(endDate) ;
            sampleSoql += sampleRegionSql;
        System.debug('samplesoql=' + sampleSoql);
        List<Sampling_Inspection__c> sampleList = Database.query(sampleSoql);
        for (Sampling_Inspection__c result : sampleList) {
            sampleIdList.add(result.Id);
        }
        if (sampleIdList.size() == 0) {
            System.debug('没有数据');
            return;
        }

        List<ContentDocumentLink> contentDocumentList = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersionId
                                                         FROM ContentDocumentLink
                                                         WHERE LinkedEntityId IN :sampleIdList];
        Map<String, List<ContentDocumentLink>> entityMap = new Map<String, List<ContentDocumentLink>>();
        if (contentDocumentList.size() > 0) {
            for (ContentDocumentLink entity : contentDocumentList) {
                String key = String.valueOf(entity.LinkedEntityId)+ String.valueOf(entity.Id);
                if (!entityMap.containsKey(key)) {
                    entityMap.put(key, new List<ContentDocumentLink>());
                }
                entityMap.get(key).add(entity);
            }
            Map<Id, Sampling_Inspection__c> checkResultMap = new Map<Id, Sampling_Inspection__c>();
            for (Sampling_Inspection__c checkResult : sampleList) {
                checkResultMap.put(checkResult.Id, checkResult);
            }
            Map<String, Integer> itemTypeCountMap = new Map<String, Integer>();
            for (String linkedEntityId : entityMap.keySet()) {
                List<ContentDocumentLink> DocumentEntity =  entityMap.get(linkedEntityId);
                String documentId = DocumentEntity[0].LinkedEntityId;
                Sampling_Inspection__c checkResult = checkResultMap.get(documentId);
                if (checkResult == null) {
                    System.debug('No CheckResult__c found for LinkedEntityId: ' + documentId);
                    continue;
                }
                for (ContentDocumentLink entity : entityMap.get(linkedEntityId)) {
                    String itemType = System.Label.Sample_Display;
                    String storeName = checkResult.Shop__r.Name;
                    String region = checkResult.Inspection_Report__r.Sales_Region__c;
                    String formattedDate = String.valueOf(checkResult.Inspection_Report__r.Report_Date__c);
                    String key = region +'_'+ storeName+'_'+ itemType +'_'+ formattedDate;                
                    Integer count = itemTypeCountMap.get(key) == null ? 1 : itemTypeCountMap.get(key) + 1;
                    itemTypeCountMap.put(key, count);
                    String newName = checkResult.Shop__r.Channel_Name__c + '_' + checkResult.Shop__r.Name + '_' + itemType + '_' + formattedDate + '_' + count;
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = newName;
                    contentVersion.Id = entity.ContentDocument.LatestPublishedVersionId;
                    entitiesToUpdate.add(contentVersion);
                }
            }
        }
    
        // 更新 ContentVersion 记录
        if (!entitiesToUpdate.isEmpty()) {
            update entitiesToUpdate;
        }
    }

    @AuraEnabled
    public static Map<String, Object> shopVerification(String shopId, String channelId){
        Map<String, Object> resp = new Map<String, Object>(); 
        List<Shop__c> stores = [Select Id,Channel_item__c from Shop__c where Id =: shopId];
        List<Shop__c> channelStores = [Select Id,Channel_item__c from Shop__c where Channel_item__c =: channelId];
        String channelItem = stores.isEmpty() ? '' : stores[0].Channel_item__c;
        String id = channelStores.isEmpty() ? '' : channelStores[0].Id;
        String storeId = channelId.equals(channelItem) ? shopId : id;
        resp.put('shopId', storeId);
        return resp;
    }

    @AuraEnabled
    public static void processCheckResults(String shopId, Date dateStart, Date dateEnd, String channel, String walker) {
        // 启动批量作业
        String sr = currentUser.Sales_Region__c;
        Update_Data_Event__c updateEvent = new Update_Data_Event__c(
            SBU__c = sr,
            Update_Status__c = 'Updating',
            Batch_Class__c = 'PhotoDownloadProcessBatch',
            ExternalKey__c = 'PhotoDownloadProcessBatch' + '-' + sr
        );
        UPSERT updateEvent ExternalKey__c;
        // ID batchId = Database.executeBatch(new PhotoDownloadProcessBatch(sr, shopId, dateStart, dateEnd, channel, walker), 1000);
        // System.debug('Batch Job ID: ' + batchId);
    }

    @AuraEnabled
    public static Update_Data_Event__c getUpdateStatus(String batchClass) {
        String sr = currentUser.Sales_Region__c;
        List<Update_Data_Event__c> updateList = [SELECT Id, Last_Update_Time__c, Update_Status__c, Disabled__c
                                                 FROM Update_Data_Event__c
                                                 WHERE Batch_Class__c = :batchClass AND SBU__c = :sr];
        if (updateList != null && updateList.size() > 0) {
            return updateList[0];
        }
        return null;
    }

}