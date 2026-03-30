public with sharing class UploadFilesController {
    
    static String itemHeadRecordTypeId = Schema.SObjectType.FileItem__c.getRecordTypeInfosByDeveloperName().get('ItemHead').getRecordTypeId();
    
    @AuraEnabled
    public static ConResponse getPackages(String[] packageIds) {
        System.debug('packageIds=' + packageIds);
        ConResponse resp = new ConResponse();
        List<FileItem__c> fileItems = new List<FileItem__c>();
        // 
        if (packageIds == null || packageIds.size() == 0) {
            return resp;
        }

        // 需求001更改 by DTT-Bright 20231018
        resp.data = [
            SELECT
                ID,
                ItemId__c,
                PackageId__c,
                RecordId__c,
                CompleteDateTime__c,
                ContentBodyId__c,
                ContentDocumentId__c,
                ContentVersionId__c
            FROM FileItem__c
            WHERE PackageId__c IN :packageIds
                AND RecordTypeId = :itemHeadRecordTypeId
        ];
        // 需求001更改 by DTT-Bright 20231018
        return resp;
    }

    /**
     * @description 获取文件列表
     * @param   recordId
     * @param   recordIds
     * @return
     */
    @AuraEnabled
    public static ConResponse getFiles(String recordId, String[] recordIds) {
        System.debug('recordId=' + recordId);
        System.debug('recordIds=' + recordIds);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        mso.put('records', new List<ContentDocument>());
        resp.data = mso;
        try {
            if (recordIds != null && recordIds.size() > 0) {
                mso.put('records', [
                    SELECT 
                        Id, 
                        ContentDocumentId, 
                        ContentBodyId, 
                        VersionNumber, 
                        Title, 
                        PathOnClient, 
                        FileType 
                    FROM ContentVersion 
                    WHERE Id IN :recordIds
                ]);
            } else if(!String.isBlank(recordId)) {
                List<ContentDocumentLink> CDLs = [
                    SELECT ContentDocumentId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId = :recordId
                ];
                if (CDLs.size() < 1) return resp; 

                // Make a List of ContentDocument IDs
                List <Id> CDIdList = new List <Id> ();
                for (ContentDocumentLink nextCDL : CDLs) {
                    CDIdList.add(nextCDL.ContentDocumentId);
                }        

                mso.put('records', [
                    SELECT 
                        Id, 
                        ContentDocumentId, 
                        ContentBodyId, 
                        VersionNumber, 
                        Title, 
                        PathOnClient, 
                        FileType 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :CDIdList and IsLatest = true
                ]);
            } else {
                return resp;
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    /**
     * @description 获取上传日期最近得一个文件图片
     * @param   recordId
     * @param   recordIds
     * @return
     */
    @AuraEnabled
    public static ConResponse getFileOne(String recordId, String[] recordIds) {
        System.debug('recordId=' + recordId);
        System.debug('recordIds=' + recordIds);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        mso.put('records', new List<ContentDocument>());
        resp.data = mso;
        try {
            if(!String.isBlank(recordId)) {
                List<ContentDocumentLink> CDLs = [
                    SELECT ContentDocumentId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId = :recordId 
                    Order By ContentDocument.CreatedDate desc limit 1
                ];
                if (CDLs.size() < 1) return resp; 

                // Make a List of ContentDocument IDs
                List <Id> CDIdList = new List <Id> ();
                for (ContentDocumentLink nextCDL : CDLs) {
                    CDIdList.add(nextCDL.ContentDocumentId);
                }        

                mso.put('records', [
                    SELECT 
                        Id, 
                        ContentDocumentId, 
                        ContentBodyId, 
                        VersionNumber, 
                        Title, 
                        PathOnClient, 
                        FileType 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :CDIdList and IsLatest = true
                ]);
            } else {
                return resp;
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    @AuraEnabled
    public static ConResponse deleteCaches(String[] packageIds){
        System.debug('packageIds=' + packageIds);
        ConResponse resp = new ConResponse();
        if (packageIds == null || packageIds.size() == 0) {
            return resp;
        }
        try {
            List<FileItem__c> fileItems = [
                SELECT
                    ID
                FROM FileItem__c
                WHERE PackageId__c IN : packageIds
            ];
            System.debug('packageIds.size=' + packageIds.size());
            delete fileItems;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }
    @AuraEnabled
    public static void uploadFile(Id recordId, Blob fileBlob, String fileName, String contentType) {
        // 创建ContentVersion对象
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = fileBlob,
            IsMajorVersion = true
        );
        insert cv;

        // 获取新创建的ContentVersion的最新版本Id
        ContentVersion latestVersion = [SELECT Id FROM ContentVersion WHERE Id =: cv.Id AND IsLatest = true LIMIT 1];
        Id contentDocumentId = latestVersion.ContentDocumentId;

        // 关联文件到记录
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = recordId,
            ContentDocumentId = contentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }
    @AuraEnabled
    public static String batchDeleteFiles(String documentIds){
        String res ='Success';
        try{
            Database.delete(documentIds);
        }catch (Exception e) {
            res ='Failed';
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            // resp.code = -1;
            // resp.message = 'error';
            // resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        return res;
    }
    @AuraEnabled
    public static ConResponse deleteFiles(String[] recordIds, String dataId){
        ConResponse resp = new ConResponse();
        if (recordIds == null || recordIds.size() == 0) {
            return resp;
        }

        Map<String, Object> mso = new Map<String, Object>();
        mso.put('records', new List<ContentDocument>());
        resp.data = mso;
        try {
            String recordId = recordIds[0];
            List<ContentDocumentLink> queryLink = [SELECT ContentDocumentId,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE ContentDocumentId = :recordId];
            List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
            for (ContentDocumentLink link : queryLink) {
                if (link.ShareType.equals('V') || !String.valueOf(link.LinkedEntityId).left(3).equals('005')) {
                    docLinks.add(link);
                }
            }
            if (docLinks.size()>1) {
                List<ContentDocumentLink> deletelinks = new List<ContentDocumentLink>();
                for (ContentDocumentLink link : docLinks) {
                    if (link.LinkedEntityId == dataId) {
                        deletelinks.add(link);
                    }
                }
                if (deletelinks.size()>0) {
                    Database.delete(deletelinks);
                }
            } else {
                Database.delete(recordId);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return resp;
    }

    public static void saveFiles(String recordListJson,String fileMapJson, List<Sobject> sobjList, String parentId) {
        System.debug('recordListJson=' + recordListJson);
        System.debug('fileMapJson=' + fileMapJson);
        System.debug('sobjList=' + sobjList);
        System.debug('parentId=' + parentId);
        List<object> lo = (List<object>)JSON.deserializeUntyped(recordListJson);
        Map<String, Object> fileMap0 = (Map<String, Object>)JSON.deserializeUntyped(fileMapJson);
        Map<Id, List<Map<String, Object>>> fileMap = new Map<Id, List<Map<String, Object>>>();
        System.debug(lo.size());
        System.debug(sobjList.size());
        for (Integer i = 0; i < lo.size() && i < sobjList.size(); i++) {
            Map<String, Object> mso = (Map<String, Object>)lo.get(i);
            if (!mso.containsKey('index') || !fileMap0.containsKey(String.valueOf(mso.get('index')))) {
                continue;
            }
            if (!fileMap.containsKey(sobjList.get(i).Id)) {
                fileMap.put(sobjList.get(i).Id, new List<Map<String, Object>>());
            }
            for(Object obj : (List<object>)fileMap0.get(String.valueOf(mso.get('index')))) {
                fileMap.get(sobjList.get(i).Id).add((Map<String, Object>)obj);
            }
        }
        saveFiles(fileMap, parentId);
    }

    public static void saveFiles2(String recordListJson,String fileMapJson, List<Sobject> sobjList, String parentId) {
        System.debug('enter saveFiles2');
        System.debug('recordListJson=' + recordListJson);
        System.debug('fileMapJson=' + fileMapJson);
        System.debug('sobjList=' + JSON.serialize(sobjList));
        List<object> lo = (List<object>)JSON.deserializeUntyped(recordListJson);
        Map<String, Object> fileMap0 = (Map<String, Object>)JSON.deserializeUntyped(fileMapJson);
        Map<Id, List<Map<String, Object>>> fileMap = new Map<Id, List<Map<String, Object>>>();
        List<FileItem__c> fileItems = new List<FileItem__c>();
        System.debug(lo.size());
        System.debug(sobjList.size());
        for (Integer i = 0; i < lo.size() && i < sobjList.size(); i++) {
            Map<String, Object> mso = (Map<String, Object>)lo.get(i);
            if (!mso.containsKey('index') || !fileMap0.containsKey(String.valueOf(mso.get('index')))) {
                continue;
            }
            if (!fileMap.containsKey(sobjList.get(i).Id)) {
                fileMap.put(sobjList.get(i).Id, new List<Map<String, Object>>());
            }
            for(Object obj : (List<object>)fileMap0.get(String.valueOf(mso.get('index')))) {
                // fileMap.get(sobjList.get(i).Id).add((Map<String, Object>)obj);
                Map<String, Object> item = (Map<String, Object>)obj;
                system.debug('item=' + item);
                if (item.get('ContentVersionId') == null) {
                    fileItems.add(new FileItem__c(
                        FileName__c = String.valueOf(item.get('name')),
                        PackageId__c = String.valueOf(item.get('packageId')),
                        ItemId__c = String.valueOf(item.get('packageId')),
                        RecordId__c = sobjList.get(i).Id,
                        RecordTypeId = itemHeadRecordTypeId
                    ));
                } else {
                    fileMap.get(sobjList.get(i).Id).add((Map<String, Object>)obj);
                }
            }
        }
        
        system.debug('fileItems.size=' + fileItems.size());
        insert fileItems;
        saveFiles(fileMap, parentId);
    }

    public static void saveFiles(Map<Id, List<Map<String,Object>>> files, String parentId) {
        Map<Id, List<ContentVersion>> fileMap = new Map<Id, List<ContentVersion>>();
        List<String> cdIds = new List<String>();
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        for (Id iid : files.keySet()) {
            List<Map<String, Object>> msList = files.get(iid);
            if (!fileMap.containsKey(iid)) {
                fileMap.put(iid, new List<ContentVersion>());
            }

            for (Map<String, Object> kv : msList) {
                System.debug(kv);
                cdIds.add(String.valueOf(kv.get('ContentDocumentId')));
                linkList.add(new ContentDocumentLink(
                    LinkedEntityId = iid,
                    ContentDocumentId = String.valueOf(kv.get('ContentDocumentId')),
                    ShareType = 'I',
                    Visibility = 'AllUsers'
                ));
                // ContentVersion cv = new ContentVersion();
                // String name = String.valueOf(kv.get('name'));
                // String base64Str = '';
                // System.debug('name=' + name);
                // Integer i = name.lastIndexOf('.');
                // cv.Title = name.substring(0, i);
                // cv.PathOnClient = name;
                // if (kv.containsKey('versionData')) {
                //     cv.VersionData = EncodingUtil.base64Decode(String.valueOf(kv.get('versionData')));
                //     //cv.VersionData = Blob.valueOf(String.valueOf(kv.get('versionData')));
                // }
                // if (kv.containsKey('src')) {
                //     base64Str = String.valueOf(kv.get('src'));
                //     i = base64Str.indexOf('base64,');
                //     cv.VersionData = EncodingUtil.base64Decode(base64Str.substring(i + 7));
                // 	//cv.VersionData = Blob.valueOf(base64Str.substring(i + 7));
                // }
                // fileMap.get(iid).add(cv);
            }
        }
        LisqContainer lc = new LisqContainer([
            SELECT
                Id, 
                LinkedEntityId, 
                ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :parentId
        ]).where1('ContentDocumentId', 'IN', cdIds);
        List<Sobject> sobjList =  lc.ToSobjectList();
        delete sobjList;
        System.debug('!linkList：' + linkList);
        for (Database.SaveResult sr : Database.insert(linkList, false)) {
            System.debug('sr=' + sr);
        }
        // saveFiles(fileMap);
    }

    public static void saveFiles(Map<Id, List<ContentVersion>> files) {
        List<ContentVersion> allFiles = new List<ContentVersion>();
        for (List<ContentVersion> cList : files.values()) {
            allFiles.addAll(cList);
        }
        
        insert allFiles;
        Map<Id,ContentVersion> allFileMap = new Map<Id,ContentVersion>(allFiles);
        Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>([
            SELECT 
                Id, 
                ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :allFileMap.keyset()
        ]);
        List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
        Map<String, ContentDocumentLink> cdlMap = new Map<String, ContentDocumentLink>();
        List<String> cdidList = new List<String>();
        for (Id iid : files.keySet()) {
            System.debug(iid);
            for (ContentVersion cv : files.get(iid)) {
                String cdid = contentVersionMap.get(cv.Id).ContentDocumentId;
                cdidList.add(cdid);
                System.debug(cdid);
                if(!cdlMap.containsKey(cdid+iid)) {
                    cdlMap.put(cdid+iid, new ContentDocumentLink(
                        ContentDocumentId = cdid,
                        LinkedEntityId = iid,
                        ShareType = 'I',
                        Visibility = 'AllUsers'
                    ));
                }
                //contentLinkList.add();
            }
        }
        Set<String> exsits = new Set<String>();
        for(ContentDocumentLink cdl : [
            SELECT
            	ID,
            	ContentDocumentId,
            	LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId in :cdidList
        ]){
            exsits.add(cdl.ContentDocumentId+ '' + cdl.LinkedEntityId);
        }
        for(String key : cdlMap.keySet()) {
            if(!exsits.contains(key)) {
                contentLinkList.add(cdlMap.get(key));
            }
        }
        
        System.debug('contentLinkList.size=' + contentLinkList.size());
        insert contentLinkList;
    }
}